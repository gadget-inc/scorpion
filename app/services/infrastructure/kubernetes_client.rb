# frozen_string_literal: true

require "shellwords"
require "securerandom"

# k8s client for executing background jobs in long lived K8S pods instead of normal background jobs. Useful for jobs that need to survive deployments (usually cause they're long)
class Infrastructure::KubernetesClient
  include SemanticLogger::Loggable

  def self.client
    @client ||= self.new
  end

  attr_reader :client

  def initialize
    @rails_pod_template_data = Rails.configuration.kubernetes.pod_template_data

    @client = if Rails.configuration.kubernetes.key?(:kube_config)
        K8s::Client.config(K8s::Config.load_file(File.expand_path(Rails.configuration.kubernetes.kube_config)))
      elsif Rails.configuration.kubernetes.key?(:in_cluster_config) && Rails.configuration.kubernetes.in_cluster_config
        K8s::Client.in_cluster_config
      else
        raise "No configuration options for ruby kubernetes client specified. Please add a kube_config location or specify in_cluster_config: true"
      end
  end

  def run_background_job_in_k8s(job_class, args, sidecar_containers: nil)
    class_name = job_class.name

    if job_class.ancestors.include?(Que::Job) && job_class.exclusive_execution_lock && !job_class.lock_available?(args)
      logger.info("Skipped k8s job enqueue as the lock is unavailable right now", job_class: job_class, args: args)
      return
    end

    create_long_running_rails_job(
      "zzjob-#{class_name.gsub(/[^A-Za-z0-9]/, "-").downcase}-#{SecureRandom.hex(5)}",
      ["bundle", "exec", "rake", "job:run_inline", "--", "--job-class", class_name, "--args", args.to_json],
      sidecar_containers: sidecar_containers,
    )
  end

  def create_long_running_rails_job(name, command, sidecar_containers: nil)
    sidecar_containers = Array.wrap(sidecar_containers)
    scheduling_group_name = "#{name}-group"

    job = K8s::Resource.new(
      apiVersion: "batch/v1",
      kind: "Job",
      metadata: {
        name: name,
        namespace: Rails.configuration.kubernetes.namespace,
        annotations: {
          "scheduling.k8s.io/group-name" => scheduling_group_name,
        },
      },
      spec: {
        completions: 1,
        parallelism: 1,
        backoffLimit: 0,
        ttlSecondsAfterFinished: 3.days.to_i,
        template: {
          metadata: {
            name: name,
          },
          spec: {
            containers: [
              {
                name: "execute-job",
                image: Rails.configuration.kubernetes.rails_image,
                command: command,
                env: @rails_pod_template_data[:rails_environment],
                volumeMounts: @rails_pod_template_data[:rails_volume_mounts],
                securityContext: { capabilities: { add: ["SYS_PTRACE"] } },
              },
            ] + sidecar_containers,
            volumes: @rails_pod_template_data[:rails_volumes],
            restartPolicy: "Never",
            priorityClassName: "standard-job",
            schedulerName: "kube-batch",
          },
        },
      },
    )

    @client.api("batch/v1").resource("jobs", namespace: Rails.configuration.kubernetes.namespace).create_resource(job)

    # kube-batch thing
    pod_group = K8s::Resource.new(
      apiVersion: "scheduling.incubator.k8s.io/v1alpha1",
      kind: "PodGroup",
      metadata: {
        name: scheduling_group_name,
        namespace: Rails.configuration.kubernetes.namespace,
      },
      spec: {
        minMember: 1,
      },
    )

    @client.api("scheduling.incubator.k8s.io/v1alpha1").resource("podgroups", namespace: Rails.configuration.kubernetes.namespace).create_resource(pod_group)
  end
end
