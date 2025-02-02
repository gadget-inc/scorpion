# frozen_string_literal: true

module CrawlTest
  # UI assistant class for rendering the crawl test dashboard
  class Dashboard
    def initialize(run_scope, limit: 10)
      @run_scope = run_scope
      @limit = limit
    end

    def property_rows
      @property_rows ||= begin
          cases_by_property = runs.map(&:crawl_test_cases).flatten.group_by(&:property_id)

          cases_by_property.map do |_property_id, cases|
            {
              property: cases[0].property,
              cases: cases.index_by(&:crawl_test_run_id),
            }
          end
        end
    end

    def runs
      @runs ||= @run_scope.includes(crawl_test_cases: :property).order("id DESC").limit(@limit)
    end

    def pass_ratio(run)
      cases = run.crawl_test_cases
      if !cases.empty?
        successful_count = cases.filter(&:successful).count
        successful_count.to_f / cases.size
      else
        0
      end
    end
  end
end
