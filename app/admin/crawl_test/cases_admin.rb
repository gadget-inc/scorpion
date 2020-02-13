# frozen_string_literal: true
require "json/add/exception"

Trestle.resource(:cases, scope: CrawlTest) do
  remove_action :destroy, :create, :update # lol

  menu do
    group :crawl_testing, priority: 50 do
      item :cases, icon: "fa fa-star"
    end
  end

  scopes do
    scope :all, -> { CrawlTest::Case.includes(:crawl_test_run).order("created_at DESC") }, default: true
    scope :failed, -> { CrawlTest::Case.includes(:crawl_test_run).where(successful: false).order("created_at DESC") }
  end

  table do
    column :id
    column :crawl_test_run
    column :successful do |test_case|
      outcome_tag(test_case.successful)
    end
    column :running do |test_case|
      running_tag(test_case.running)
    end
    column :created_at, align: :center
    column :finished_at, align: :center
    actions
  end

  form do |test_case|
    tab :details do
      static_field :property, admin_link_to(test_case.property.name, test_case.property)
      static_field :crawl_test_run, admin_link_to(test_case.crawl_test_run.name, test_case.crawl_test_run)
      static_field :running, running_tag(test_case.running)
      static_field :successful, outcome_tag(test_case.successful)
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
            e = Exception.json_create(test_case.error)
            (["#{e.class.name}: #{e.message}"] + Rails.backtrace_cleaner.clean(e.backtrace).map { |s| "\t#{s}" }).map { |s| tag.span(s) }.join(tag.br).html_safe # rubocop:disable Rails/OutputSafety
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

    tab :failure_html do
      if test_case.last_html.present?
        link_to("Render raw HTML at failure time", admin.path(:raw_html, id: test_case.id))
      else
        content_tag(:span, "No raw HTML captured", class: "blank")
      end
    end
  end

  controller do
    def raw_html
      test_case = admin.find_instance(params)
      render html: test_case.last_html.try(:html_safe?), layout: false
    end
  end

  routes do
    get :raw_html, on: :member
  end
end
