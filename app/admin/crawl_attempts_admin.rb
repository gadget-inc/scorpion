# frozen_string_literal: true

Trestle.resource(:crawl_attempts) do
  menu do
    item :crawl_attempts, icon: "fa fa-spider"
  end

  scopes do
    scope :all, -> { CrawlAttempt.order("created_at DESC") }, default: true
    scope :failed, -> { CrawlAttempt.where("succeeded IS NULL or succeeded = false").order("created_at DESC") }
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
      link_to "Logs", CrawlAttemptHelper.logs_url(attempt), target: "_blank", rel: "noopener"
    end
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |app|
  #   text_field :name
  #
  #   row do
  #     col(xs: 6) { datetime_field :updated_at }
  #     col(xs: 6) { datetime_field :created_at }
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
  #   params.require(:app).permit(:name, ...)
  # end
end
