# frozen_string_literal: true
Trestle.resource(:cases, scope: CrawlTest) do
  menu do
    group :crawl_testing, priority: 50 do
      item :cases, icon: "fa fa-star"
    end
  end

  scopes do
    scope :all, -> { CrawlTest::Case.order("created_at DESC") }, default: true
    scope :failed, -> { CrawlTest::Case.where(successful: false).order("created_at DESC") }
  end

  table do
    column :id
    column :crawl_test_run
    column :successful
    column :running
    column :created_at, align: :center
    column :finished_at, align: :center
    actions
  end

  form do |test_case|
    tab :details do
      static_field :property, admin_link_to(test_case.property.name, test_case.property)
      static_field :crawl_test_run, admin_link_to(test_case.crawl_test_run.name, test_case.crawl_test_run)
      static_field :running
      static_field :successful
      static_field :created_at
      static_field :started_at
      static_field :finished_at
    end

    tab :logs do
      tag.div do
        concat tag.h3 "Logs (#{test_case.logs.size} total)"
        test_case.logs.map do |log|
          concat(tag.p do
            tag.span { log["message"] } +
            tag.code(style: "margin-left: 1rem") do
              log["args"].inspect
            end
          end)
        end

        concat tag.h3 "Error"
        concat(tag.code do
          if test_case.error
            JSON.pretty_generate(test_case.error)
          else
            "No error"
          end
        end)
      end
    end

    if test_case.screenshot.attached?
      tab :screenshot do
        image_tag Rails.application.routes.url_helpers.rails_blob_path(test_case.screenshot, host: Rails.configuration.x.domains.admin)
      end
    end
  end
end
