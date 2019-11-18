# frozen_string_literal: true
module Crawler
  class ExecuteCrawl
    include SemanticLogger::Loggable

    def self.run_in_background(connection)
      args = [{ connection_id: connection.id }]
      if Rails.env.production?
        KubernetesClient.client.run_background_job_in_k8s(Infrastructure::SyncSingerConnectionJob, args)
      else
        raise NotImplementedError
        # Infrastructure::SyncSingerConnectionJob.enqueue(*args)
      end
    end

    def initialize(account)
      @account = account
    end

    def crawl(property, reason)
      attempt_record = @account.crawl_attempts.create!(property: property, started_reason: reason, started_at: Time.now.utc, last_progress_at: Time.now.utc)

      logger.tagged property_id: property.id, crawl_attempt_id: attempt_record.id do
        begin
          logger.info "Beginning crawl for property"

          CrawlerClient.client.crawl(
            property,
            crawl_options: { maxDepth: 1 },
            on_result: proc do |result|
              CrawlAttempt.transaction do
                attempt_record.update!(last_progress_at: Time.now.utc)
                @account.crawl_pages.create!(property: property, crawl_attempt: attempt_record, url: result["url"], result: result)
              end
            end,
            on_error: proc do |error_result|
              CrawlAttempt.transaction do
                attempt_record.update!(last_progress_at: Time.now.utc)
                @account.crawl_pages.create!(property: property, crawl_attempt: attempt_record, url: error_result["url"], result: { error: error })
              end
            end,
          )
        rescue StandardError => e
          attempt_record.update!(finished_at: Time.now.utc, succeeded: false, failure_reason: e.message)
          raise
        end

        logger.info "Crawl completed successfully"
        attempt_record.update!(finished_at: Time.now.utc, succeeded: true)
      end
    end
  end
end
