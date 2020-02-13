# frozen_string_literal: true
Trestle.admin(:dashboard, scope: CrawlTest) do
  menu do
    group :crawl_testing, priority: 50 do
      item :dashboard, icon: "fa fa-tachometer", priority: :first
    end
  end

  controller do
    def index
      @dashboard = CrawlTest::Dashboard.new(CrawlTest::Run.where(endpoint: "/interaction/shopify_browse_add"), limit: 6)
    end
  end
end
