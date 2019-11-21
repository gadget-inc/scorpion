# frozen_string_literal: true
module Crawler
  class ExecuteCrawl
    include SemanticLogger::Loggable

    DEFAULT_CRAWL_OPTIONS = { maxDepth: 30 }.freeze

    def self.run_in_background(property, reason, force_kubernetes: false)
      args = [{ property_id: property.id, reason: reason }]
      if Rails.env.production? || force_kubernetes
        Infrastructure::KubernetesClient.client.run_background_job_in_k8s(
          Crawler::ExecuteCrawlJob,
          args,
          sidecar_containers: [
            {
              name: "scorpion-crawler",
              image: Rails.configuration.crawler[:container_image],
              env: [{ name: "NODE_ENV", value: "production" }, { name: "PORT", value: "3005" }],
              ports: [{ containerPort: 3005 }],
              resources: {
                requests: {
                  memory: "1Gi",
                },
                limits: {
                  memory: "1Gi",
                },
              },
            },
          ],
        )
      else
        Crawler::ExecuteCrawlJob.enqueue(*args)
      end
    end

    def initialize(account, crawl_options = DEFAULT_CRAWL_OPTIONS)
      @account = account
      @crawl_options = crawl_options
    end

    def crawl(property, reason)
      CrawlerClient.client.block_until_available

      attempt_record = @account.crawl_attempts.create!(property: property, started_reason: reason, started_at: Time.now.utc, last_progress_at: Time.now.utc, running: true)

      logger.tagged property_id: property.id, crawl_attempt_id: attempt_record.id do
        logger.silence(:info) do
          logger.info "Beginning crawl for property"

          CrawlerClient.client.crawl(
            property,
            crawl_options: crawl_options,
            on_result: proc do |result|
              CrawlAttempt.transaction do
                attempt_record.update!(last_progress_at: Time.now.utc)
                @account.crawl_pages.create!(property: property, crawl_attempt: attempt_record, url: result["url"], result: result)
              end
            end,
            on_error: proc do |error_result|
              CrawlAttempt.transaction do
                attempt_record.update!(last_progress_at: Time.now.utc)
                @account.crawl_pages.create!(property: property, crawl_attempt: attempt_record, url: error_result["url"], result: { error: error_result })
              end
            end,
            on_log: proc do |log|
              logger.info("remote crawler log", log)
            end,
          )
        rescue StandardError => e
          attempt_record.update!(finished_at: Time.now.utc, succeeded: false, failure_reason: e.message, running: false)
          raise
        end

        logger.info "Crawl completed successfully"
        attempt_record.update!(finished_at: Time.now.utc, succeeded: true, running: false)
      end
    end

    def crawl_options
    end
  end
end
