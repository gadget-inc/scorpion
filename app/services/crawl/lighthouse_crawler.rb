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
          uses-optimized-images
          offscreen-images
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
      @issue_governor = Assessment::IssueGovernor.new(@property, "lighthouse")
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
      result["lighthouse"]["audits"].map do |_key, audit|
        @issue_governor.make_assessment("lighthouse-#{audit["id"]}", key_category_for_audit(audit["id"], result["url"])) do |assessment|
          assessment.score_mode = audit["scoreDisplayMode"]
          assessment.details = { lighthouse_details: audit["details"] }
          assessment.url = result["url"]
          if audit["scoreDisplayMode"] != "error"
            assessment.score = (audit["score"] * 100).round
          else
            assessment.error_code = "LIGHTHOUSE_ERROR"
            assessment.score = 0
          end
        end
      end
      @lifecycle.register_progress!
    end

    def store_error_result(error_result)
      LIGHTHOUSE_CONFIG[:settings][:onlyAudits].map do |audit_id|
        @issue_governor.make_assessment("lighthouse-#{audit_id}", key_category_for_audit(audit_id, error_result["url"])) do |assessment|
          assessment.score = 0
          assessment.score_mode = "binary"
          assessment.error_code = error_code(error_result)
          assessment.url = error_result["url"]
        end
      end

      @lifecycle.register_progress!
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
      when "interactive", "speed-index", "uses-optimized-images", "offscreen-images"
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
