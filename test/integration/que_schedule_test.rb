# frozen_string_literal: true
require "test_helper"

class QueScheduleTest < ActiveSupport::TestCase
  test "all scheduler keys can be constantized" do
    Que::Scheduler.schedule.each_key do |job_class|
      assert job_class.constantize
    end
  end
end
