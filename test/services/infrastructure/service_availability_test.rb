# frozen_string_literal: true

require "test_helper"

module Infrastructure
  class ServiceAvailabilityTest < ActiveSupport::TestCase
    test "it can assert that a service is available" do
      assert ServiceAvailability.test("localhost", 5432)
      assert_not ServiceAvailability.test("localhost", 5433)
    end

    test "it can assert on a uri" do
      assert ServiceAvailability.test_uri("tcp://localhost:5432")
      assert ServiceAvailability.test_uri("https://google.ca:443")
      assert_not ServiceAvailability.test_uri("tcp://localhost:5433")
    end
  end
end
