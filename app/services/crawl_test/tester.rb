# frozen_string_literal: true
require "faker"
require "json/add/exception"

module CrawlTest
  class Tester
    include SemanticLogger::Loggable

    def self.generate_name
      [Faker::ElectricalComponents.active, Faker::ElectricalComponents.passive, Faker::ElectricalComponents.electromechanical, Faker::Appliance.brand, Faker::Hacker.noun, Faker::Hacker.verb, Faker::House.furniture, Faker::House.room].sample(2).join("-").parameterize
    end

    def enqueue_run(name: nil, endpoint:, user:, property_limit: 50, property_criteria: nil)
      run = Run.create!(name: name || self.class.generate_name, running: false, started_by: user, endpoint: endpoint, property_criteria: property_criteria, property_limit: property_limit)
      properties = ::Property.for_crawl_testing.order("id ASC").limit(property_limit)

      now = Time.now.utc
      cases = properties.map do |property|
        {
          property_id: property.id,
          crawl_test_run_id: run.id,
          running: false,
          created_at: now,
          updated_at: now,
        }
      end

      case_returns = Case.insert_all!(cases)
      case_returns.each do |case_return|
        ExecuteTestCaseJob.enqueue(crawl_test_case_id: case_return["id"])
      end

      run
    end

    def execute_case(test_case)
      logger.tagged test_case_id: test_case.id do
        logger.silence(:info) do
          test_case.update!(finished_at: Time.now.utc, successful: true, running: false)
          logger.info "Beginning crawl for test case"

          client = ::Crawler::CrawlerClient.client
          success = true
          error = nil

          client.request(
            test_case.crawl_test_run.endpoint,
            { property: client.property_blob(test_case.property), startPage: test_case.property.crawl_roots[0] },
            on_result: proc do |result|
              if result.key?("screenshot")
                test_case.screenshot.attach(
                  io: StringIO.new(Base64.decode64(result["screenshot"])),
                  filename: "test_case_#{test_case.id}_screenshot.png",
                  content_type: "application/png",
                  identify: false,
                )
              end
            end,
            on_error: proc do |err|
              error = err
              success = false
            end,
            on_log: proc do |log|
              test_case.logs << log
              test_case.save!
            end,
          )

          logger.info "Crawl completed", success: success
          test_case.update!(finished_at: Time.now.utc, successful: success, error: error, running: false)
        rescue StandardError => e
          test_case.update!(finished_at: Time.now.utc, successful: false, error: e, running: false)
          raise
        end
      end
    end
  end
end
