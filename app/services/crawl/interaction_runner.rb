# frozen_string_literal: true

module Crawl
  # Invokes an interaction script using the crawler service and then stores the produced assessment results
  class InteractionRunner
    include SemanticLogger::Loggable

    attr_reader :property, :production_group

    def initialize(property, production_group)
      @property = property
      @production_group = production_group
      @issue_governor = Assessment::IssueGovernor.new(@property, production_group, "interactions")
    end

    def test_interaction(interaction_id)
      @lifecycle = CrawlLifecycle.new(@property, @production_group.reason, :interaction)
      @lifecycle.run do |attempt_record|
        success = true
        error = nil

        begin
          CrawlerClient.client.interaction(
            @property,
            interaction_id,
            @property.key_urls[0].url, # TODO: stop assuming this is correct
            trace_context: { crawlAttemptId: attempt_record.id },
            on_result: proc do |result|
              store_result(result)
            end,
            on_error: proc do |error_result|
              error = error_result
              success = false
            end,
            on_log: proc do
              @lifecycle.register_progress!
            end,
          )
        rescue CrawlerClient::CrawlExecutionError => e
          error = e
          success = false
        end

        @issue_governor.make_assessment("interaction-#{interaction_id}", key_category_for_id(interaction_id)) do |assessment|
          assessment.assign_attributes({
            score: success ? 1 : 0,
            score_mode: "binary",
            error_code: categorize_error(error),
            details: { error: error },
          })
        end
      end
    end

    def store_result(_result)
      # TODO: store screenshots and whatnot
      true
    end

    def key_category_for_id(id)
      case id
      when "shopify-browse-add" then "checkout"
      else
        throw "Unknown interaction id #{id} for categorization"
      end
    end

    def categorize_error(error)
      if error.nil?
        nil
      else
        # TODO: categorize properly
        "ERROR"
      end
    end
  end
end
