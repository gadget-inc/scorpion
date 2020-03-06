# frozen_string_literal: true

module Crawl
  class CrawlLifecycle
    include SemanticLogger::Loggable
    attr_reader :property, :account, :reason, :type

    def initialize(property, reason, type)
      @property = property
      @account = property.account
      @reason = reason
      @crawl_type = type
    end

    def run
      @attempt_record = @account.crawl_attempts.create!(
        property: @property,
        started_reason: @reason,
        crawl_type: @crawl_type,
        started_at: Time.now.utc,
        last_progress_at: Time.now.utc,
        running: true,
      )

      logger.tagged property_id: @property.id, crawl_attempt_id: @attempt_record.id do
        logger.silence(:info) do
          logger.info "Beginning crawl for property"
          yield @attempt_record
        rescue StandardError => e
          @attempt_record.update!(finished_at: Time.now.utc, succeeded: false, failure_reason: e.message, running: false)
          raise
        end

        logger.info "Crawl completed successfully"
        @attempt_record.update!(finished_at: Time.now.utc, succeeded: true, running: false)
      end

      @attempt_record
    end

    def register_progress!
      @attempt_record.update!(last_progress_at: Time.now.utc)
    end
  end
end
