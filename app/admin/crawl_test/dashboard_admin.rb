# frozen_string_literal: true
Trestle.admin(:dashboard, scope: CrawlTest) do
  menu do
    group :crawl_testing, priority: 50 do
      item :dashboard, icon: "fa fa-tachometer"
    end
  end

  controller do
    def index
    end
  end
end
