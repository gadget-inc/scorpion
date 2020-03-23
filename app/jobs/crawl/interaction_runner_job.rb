# frozen_string_literal: true

class Crawl::InteractionRunnerJob < Que::Job
  self.maximum_retry_count = 0
  self.exclusive_execution_lock = true
  self.queue = "crawls"

  def run(property_id:, production_group_id:, interaction_id:)
    property = Property.find(property_id)
    production_group = Assessment::ProductionGroup.find(production_group_id)
    Crawl::InteractionRunner.new(property, production_group).test_interaction(interaction_id)
  end
end
