# frozen_string_literal: true

require "test_helper"

class CrawlTest::AssessorTest < ActiveSupport::TestCase
  setup do
    @ambient_homesick = create(:ambient_homesick_property)
    @production_group = create(:assessment_production_group, property: @ambient_homesick)
  end

  test "creates a bunch of assessments for an ambient property" do
    CrawlTest::Assessor.new(@ambient_homesick, @production_group).run_all
  end
end
