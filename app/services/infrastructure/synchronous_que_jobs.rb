# frozen_string_literal: true
module Infrastructure
  # Run que jobs inline for a block
  module SynchronousQueJobs
    def self.with_synchronous_jobs
      old_value = Que::Job.run_synchronously
      Que::Job.run_synchronously = true
      yield
    ensure
      Que::Job.run_synchronously = old_value
    end

    def with_synchronous_jobs(&block)
      Infrastructure::SynchronousQueJobs.with_synchronous_jobs(&block)
    end
  end
end
