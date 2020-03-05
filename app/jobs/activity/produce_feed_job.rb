# frozen_string_literal: true
module Activity
  class ProduceFeedJob < Que::Job
    self.exclusive_execution_lock = true

    def run(property_id:)
      property = Property.kept.find(property_id)
      FeedProducer.new(property).produce
    end
  end
end
