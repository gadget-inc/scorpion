# frozen_string_literal: true
Trestle.admin(:infrastructure, path: "infrastructure") do
  menu do
    item :infrastructure, icon: "fa fa-flag"
  end

  controller do
    def run_infrastructure_job
      job = case params[:job_type]
        when "high_frequency"
          Infrastructure::PeriodicHighFrequencyEnqueueJob
        when "medium_frequency"
          Infrastructure::PeriodicMediumFrequencyEnqueueJob
        when "reinstall_webhooks"
          Infrastructure::ReinstallAllWebhooksJob
        when "assess_all"
          CrawlTest::PeriodicExecuteAssessmentsJob
        else
          raise "Unknown job type for enqueue: #{params[:job_type]}"
        end

      # Lazy
      if Rails.env.development?
        begin
          old_value = Que::Job.run_synchronously
          Que::Job.run_synchronously = true
          job.run
        ensure
          Que::Job.run_synchronously = old_value
          flash[:message] = "Global #{job.name} job run"
        end
      else
        job.enqueue
        flash[:message] = "Global #{job.name} job enqueued"
      end

      redirect_to admin.path
    end
  end

  routes do
    post :run_infrastructure_job
  end
end
