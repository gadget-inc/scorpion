# frozen_string_literal: true

module Crawl
  # Invokes lighthouse using the crawler service and then categorizes, decorates, and stores the produced assessment results
  class LighthouseCrawler
    include SemanticLogger::Loggable

    LIGHTHOUSE_CONFIG = {
      extends: "lighthouse:default",
      settings: {
        onlyAudits: %w[
          interactive
          speed-index
          viewport
          errors-in-console
          image-aspect-ratio
          document-title
          no-vulnerable-libraries
          password-inputs-can-be-pasted-into
          uses-passive-event-listeners
          meta-description
          font-size
          link-text
          tap-targets
          hreflang
        ],
      },
    }.freeze

    DEFAULT_CRAWL_OPTIONS = {}.freeze

    attr_reader :property, :crawl_options, :reason

    def initialize(property, reason, crawl_options = DEFAULT_CRAWL_OPTIONS)
      @property = property
      @crawl_options = crawl_options
      @reason = reason
      @url_categorizer = Identity::UrlCategorizer.new(@property)
    end

    def collect_lighthouse_crawl
      @lifecycle = CrawlLifecycle.new(@property, @reason, :collect_lighthouse)
      @lifecycle.run do |attempt_record|
        CrawlerClient.client.lighthouse(
          @property,
          @property.key_urls.map(&:url),
          lighthouse_config: LIGHTHOUSE_CONFIG,
          crawl_options: @crawl_options,
          trace_context: { crawlAttemptId: attempt_record.id },
          on_result: proc { |result| store_result(result) },
          on_error: proc { |error_result| store_error_result(error_result) },
        )
      end
    end

    def store_result(result)
      assessments = result["lighthouse"]["audits"].map do |_key, audit|
        record = base_assessment_record(audit["id"], result["url"])
        record.score = (audit["score"] * 100).round
        record.score_mode = audit["scoreDisplayMode"]
        record.details = { lighthouse_details: audit["details"] }
        record
      end

      Crawl::Attempt.transaction do
        @lifecycle.register_progress!
        assessments.each(&:save!)
      end
    end

    def store_error_result(error_result)
      assessments = LIGHTHOUSE_CONFIG[:settings][:onlyAudits].map do |audit_id|
        record = base_assessment_record(audit_id, error_result["url"])
        record.score = 0
        record.score_mode = "binary"
        record.error_code = error_code(error_result)
        record
      end

      Crawl::Attempt.transaction do
        @lifecycle.register_progress!
        assessments.each(&:save!)
      end
    end

    def base_assessment_record(id, url)
      @property.assessment_results.build(
        account_id: @property.account_id,
        key: "lighthouse-#{id}",
        assessment_at: Time.now.utc,
        url: url,
        key_category: key_category_for_audit(id, url),
      )
    end

    def key_category_for_audit(id, url)
      case id
      when "interactive", "speed-index"
        :performance
      when "no-vulnerable-libraries", "password-inputs-can-be-pasted-into"
        :security
      when "meta-description", "font-size", "link-text", "hreflang", "document-title"
        :seo
      when "tap-targets", "uses-passive-event-listeners", "viewport", "image-aspect-ratio"
        :design
      when "errors-in-console"
        @url_categorizer.categorize(url)
      else
        throw "Unknown audit ID #{id} for categorization"
      end
    end

    def error_code(_error_result)
      "ERROR"
    end
  end
end
