# frozen_string_literal: true

require "base64"

module Crawler
  class ExecuteCrawl
    include SemanticLogger::Loggable

    DEFAULT_CRAWL_OPTIONS = { maxDepth: 4 }.freeze

    def self.run_in_background(property, reason, type)
      job_class = case type
        when :collect_screenshots
          Crawler::ExecuteCollectScreenshotsCrawlJob
        when :collect_page_info
          Crawler::ExecuteCollectPageInfoCrawlJob
        when :collect_lighthouse
          Crawler::ExecuteCollectLighthouseCrawlJob
        else
          raise "Unknown crawl type #{type}"
        end

      job_class.enqueue(property_id: property.id, reason: reason)
    end

    attr_reader :crawl_options

    def initialize(account, crawl_options = DEFAULT_CRAWL_OPTIONS)
      @account = account
      @crawl_options = crawl_options
    end

    def collect_page_info_crawl(property, reason)
      attempt_crawl(property, reason, :collect_page_info) do |attempt_record|
        CrawlerClient.client.crawl(property, **default_crawl_arguments(property, attempt_record))
      end
    end

    def collect_screenshots_crawl(property, reason)
      attempt_crawl(property, reason, :collect_screenshots) do |attempt_record|
        CrawlerClient.client.screenshots(
          property,
          property.crawl_roots,
          **default_crawl_arguments(property, attempt_record),
          on_result: proc do |result|
            CrawlAttempt.transaction do
              attempt_record.update!(last_progress_at: Time.now.utc)
              image_data = result.delete("base64Image")
              @account.property_screenshots.create!(
                property: property,
                crawl_attempt: attempt_record,
                url: result.fetch("url"),
                result: result,
                image: {
                  io: StringIO.new(Base64.decode64(image_data)),
                  filename: "#{Zaru.sanitize!(result.fetch("url"), fallback: "unknown")}_screenshot.png",
                  content_type: "application/png",
                  identify: false,
                },
              )
            end
          end,
          on_error: proc do |error_result|
            CrawlAttempt.transaction do
              attempt_record.update!(last_progress_at: Time.now.utc)
              logger.info("remote crawler error", error_result)
            end
          end,
        )
      end
    end

    def collect_lighthouse_crawl(property, reason)
      attempt_crawl(property, reason, :collect_lighthouse) do |attempt_record|
        CrawlerClient.client.lighthouse(
          property,
          property.crawl_roots,
          **default_crawl_arguments(property, attempt_record),
        )
      end
    end

    protected

    def attempt_crawl(property, reason, crawl_type)
      if Rails.configuration.crawler[:run_as_kubernetes_job]
        CrawlerClient.client.block_until_available
      end

      attempt_record = @account.crawl_attempts.create!(property: property, started_reason: reason, crawl_type: crawl_type, started_at: Time.now.utc, last_progress_at: Time.now.utc, running: true)

      logger.tagged property_id: property.id, crawl_attempt_id: attempt_record.id do
        logger.silence(:info) do
          logger.info "Beginning crawl for property"
          yield attempt_record
        rescue StandardError => e
          attempt_record.update!(finished_at: Time.now.utc, succeeded: false, failure_reason: e.message, running: false)
          raise
        end

        logger.info "Crawl completed successfully"
        attempt_record.update!(finished_at: Time.now.utc, succeeded: true, running: false)
      end

      attempt_record
    end

    def default_crawl_arguments(property, attempt_record)
      {
        crawl_options: crawl_options,
        trace_context: { crawlAttemptId: attempt_record.id },
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
      }
    end
  end
end
