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

  # Customize the form fields shown on the new/edit views.
  #
  # form do |case|
  #   text_field :name
  #
  #   row do
  #     col { datetime_field :updated_at }
  #     col { datetime_field :created_at }
  #   end
  # end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:case).permit(:name, ...)
  # end
end
