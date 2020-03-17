# frozen_string_literal: true

require "test_helper"

module CrawlTest
  class AssessorTest < ActiveSupport::TestCase
    setup do
      @ambient_homesick = create(:ambient_homesick_property)
    end

    test "creates a bunch of assessments for an ambient property" do
      Assessor.new(@ambient_homesick).run_all
    end
  end
end
