# frozen_string_literal: true

require "que"

# Monkeypatch the Que logger to send log events with the event as the first parameter, and all it's semantic juicy goodness as keyword arguments to the semantic-logger gem
# for correct and pluggable formatting of the extra data.
module Que
  module Utils
    module Logging
      attr_accessor :logger, :internal_logger
      attr_writer :log_formatter

      def log(event:, level: :info, **extra)
        data = _default_log_data
        data.merge!(extra)

        SemanticLogger[Que].send(level, event, **data)
      end
    end
  end
end

Que.logger = SemanticLogger[Que]

Que.error_notifier = proc do |error, job|
  Que.logger.error(error.message, job)
  Raven.capture_exception(error, extra: { job: job })
end

UnitOfWorkMiddleware = lambda { |job, &block|
  Infrastructure::UnitOfWork.unit("QueJob/#{job.que_attrs[:job_class]}") do |unit|
    unit.add_tags(job_id: job.que_attrs[:id])
    begin
      block.call
    rescue StandardError => e
      unit.add_tags(job_outcome: "failure", job_exception: e.message)
      raise e
    else
      unit.add_tags(job_outcome: "success")
    end
  end
}

Que.job_middleware.push(UnitOfWorkMiddleware)
