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

      properties = ::Property.for_ambient_crawls.order("id ASC").limit(property_limit)
      if property_criteria.present?
        properties = properties.admin_search(property_criteria)
      end

      create_cases(run, properties)

      run
    end

    def reenqueue_run(run:, user:, name: nil)
      new_run = Run.create!(name: name || self.class.generate_name, running: false, started_by: user, endpoint: run.endpoint, property_criteria: run.property_criteria, property_limit: run.property_limit)

      create_cases(new_run, run.properties)

      new_run
    end

    def execute_case(test_case)
      logger.tagged test_case_id: test_case.id do
        logger.silence(:info) do
          test_case.update!(started_at: Time.now.utc, running: true)
          logger.info "Beginning crawl for test case"

          client = ::Crawler::CrawlerClient.client
          success = true
          error = nil

          client.request(
            test_case.crawl_test_run.endpoint,
            test_request_body(test_case),
            trace_context: { "testRunId" => test_case.crawl_test_run.id, "testCaseId" => test_case.id },
            on_result: proc do |result|
              if result.key?("screenshot")
                test_case.screenshot.attach(
                  io: StringIO.new(Base64.decode64(result["screenshot"])),
                  filename: "test_case_#{test_case.id}_screenshot.png",
                  content_type: "application/png",
                  identify: false,
                )
              end

              if result.key?("html")
                test_case.update!(last_html: result["html"])
              end
            end,
            on_error: proc do |err|
              error = err
              success = false
            end,
            on_log: proc do |log|
              CrawlTest::CaseLog.create!(crawl_test_case_id: test_case.id, message: log["message"], metadata: log["metadata"])
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

    private

    def create_cases(run, properties)
      if properties.empty?
        throw "No properties to run test run on"
      end

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
    end

    def test_request_body(test_case)
      client = ::Crawler::CrawlerClient.client

      body = {}
      if test_case.property.internal_test_options
        body.merge!(test_case.property.internal_test_options)
      end

      body[:property] = client.property_blob(test_case.property)
      body[:startPage] = test_case.property.crawl_roots[0]

      body
    end
  end
end
