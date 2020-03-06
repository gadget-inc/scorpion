# frozen_string_literal: true

# Wrapper object around requests and jobs providing a global context to set instrumentation values and callbacks on. Useful for doing work at the end of the work unit, but only once even if multiple things merit it using :idempotency_key
class Infrastructure::UnitOfWork
  thread_cattr_accessor :current

  class << self
    def unit(name, &block)
      if self.current.nil?
        begin
          unit = self.new(name)
          self.current = unit
          unit.run(&block)
        ensure
          self.current = nil
        end
      else
        yield current
      end
    end

    def add_tags(tags)
      current.try(:add_tags, tags)
    end

    def on_success(options = {}, &block)
      if current
        current.on_success(options, &block)
      else
        yield
      end
    end
  end

  def initialize(name)
    @name = name
    @success_callbacks = []
    @idempotent_success_callbacks = {}
  end

  def run
    already_in_raven_transaction = Raven.context.transaction.present?
    if !already_in_raven_transaction
      Raven.context.transaction.push(@name)
    end

    Honeycomb.start_span(name: "unit_of_work") do |span|
      span.add_field("unit_of_work_name", @name)
      yield self
      @success_callbacks.each(&:call)
      @idempotent_success_callbacks.values.each(&:call)
    end
  ensure
    if !already_in_raven_transaction
      Raven.context.transaction.pop
    end
  end

  def add_tags(tags)
    Raven.tags_context(tags)
    tags.each do |key, value|
      Honeycomb.add_field(key.to_s, value)
    end
  end

  def on_success(idempotency_key: nil, &block)
    if !idempotency_key.nil?
      @idempotent_success_callbacks[idempotency_key] ||= block
    else
      @success_callbacks << block
    end
  end
end
