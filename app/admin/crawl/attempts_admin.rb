# frozen_string_literal: true

Trestle.resource(:attempts, scope: Crawl) do
  menu do
    item :crawl_attempts, icon: "fa fa-spider"
  end

  scopes do
    scope :all, -> { Crawl::Attempt.order("created_at DESC") }, default: true
    scope :ambient, -> { Crawl::Attempt.all.joins(:property).where(properties: { ambient: true }) }
    scope :specific, -> { Crawl::Attempt.all.joins(:property).where(properties: { ambient: false }) }
    scope :failed, -> { Crawl::Attempt.where("succeeded IS NULL or succeeded = false").order("created_at DESC") }
  end

  table do
    column :id
    column :account
    column :property
    column :crawl_type, link: true
    column :succeeded
    column :started_at
    column :started_reason
    column :last_progress_at
    column :finished_at
    column :failure_reason
    column :links do |attempt|
      link_to "Logs", Crawl::AttemptHelper.logs_url(attempt), target: "_blank", rel: "noopener"
    end
  end

  form do |crawl_attempt|
    tab :pages, badge: crawl_attempt.crawl_pages.size do
      table crawl_attempt.crawl_pages.order("id ASC") do
        column :id
        column :url
        column :error do |page|
          page.result["error"].present?
        end
        column :result do |page|
          tag.pre do
            tag.code do
              page.result.to_s.truncate(100)
            end
          end
        end
      end
    end

    if crawl_attempt.type_collect_screenshots?
      tab :screenshots do
        table crawl_attempt.property_screenshots.order("id ASC") do
          column :id
          column :url
          column :image do |screenshot|
            if screenshot.image
              image_tag Rails.application.routes.url_helpers.rails_blob_path(screenshot.image, host: Rails.configuration.x.domains.admin)
            end
          end
        end
      end
    end

    tab :form do
      text_field :failure_reason
      text_field :crawl_type
    end
  end

  routes do
    post :reprocess_spelling, on: :member
  end
end
