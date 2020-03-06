# frozen_string_literal: true

class Crawl::InteractionRunnerJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, reason:, interaction_id:)
    property = Property.find(property_id)
    Crawl::InteractionRunner.new(property, reason).test_interaction(interaction_id)
  end
end
