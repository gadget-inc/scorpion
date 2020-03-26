# frozen_string_literal: true

Trestle.resource(:properties) do
  menu do
    item :properties, icon: "fa fa-boxes"
  end

  scopes do
    scope :all, -> { Property.includes(:account).order("created_at DESC") }
    scope :active, -> { Property.includes(:account).order("created_at DESC").where(ambient: false) }, default: true
    scope :ambient, -> { Property.includes(:account).order("created_at DESC").where(ambient: true) }
  end

  search do |query|
    query ? collection.admin_search(query) : collection
  end

  table do
    column :id
    column :enabled
    column :ambient
    column :name
    column :internal_tags
    column :crawl_roots do |property|
      property.crawl_roots.map do |root|
        tag.a(href: root) { root }
      end
    end

    column :account
    column :created_at, align: :center
    actions
  end

  build_instance do |attrs, _params|
    instance = Property.new(attrs)
    instance.ambient ||= true
    instance.creator_id ||= User.first.id
    instance.account_id ||= Account.first.id
    instance
  end

  form do |property|
    if !property.new_record?
      sidebar do
        concat link_to("Crawl key urls now", admin.path(:enqueue_crawl, id: property.id, crawl_type: "key_urls"), method: :post, class: "btn btn-block btn-primary")
      end

      tab :activity_feed do
        table property.activity_feed_items.order("item_at DESC") do
          column :id
          column :item_at
          column :item_type
          actions
        end
      end

      tab :crawl_attempts, badge: property.crawl_attempts.size do
        table property.crawl_attempts.order("started_at DESC"), admin: :crawl_attempts do
          column :id
          column :crawl_type, link: true
          column :started_at, link: true
          column :started_reason
          column :running, align: :center
          column :succeeded, align: :center
          column :failure_reason
          actions
        end
      end

      tab :interaction_test_cases, badge: property.crawl_test_cases.size do
        table property.crawl_test_cases.includes(:crawl_test_run).order("id DESC"), admin: :crawl_test_cases do
          column :id
          column :crawl_test_run
          column :started_at, link: true
          column :running, align: :center
          column :successful, align: :center
          actions
        end
      end
    end

    tab :property_details do
      text_field :name
      select :account_id, Account.all
      select :creator_id, User.all
      check_box :ambient
      select :crawl_roots, nil, {}, multiple: true, data: { tags: true, select_on_close: true }
      select :allowed_domains, nil, {}, multiple: true, data: { tags: true, select_on_close: true }
      select :internal_tags, nil, {}, multiple: true, data: { tags: true, select_on_close: true }
      json_editor :internal_test_options
      static_field :created_at
      static_field :updated_at
    end
  end

  controller do
    def enqueue_crawl
      property = admin.find_instance(params)
      case crawl_type
      when "key_urls"
        Crawl::KeyUrlsCrawlJob.enqueue(property_id: property.id, reason: "admin trigger")
      else
        throw "Unknown crawl type #{params[:crawl_type]} error"
      end
      flash[:message] = "Property #{params[:crawl_type]} crawl enqueued"
      redirect_to admin.path(:show, id: property)
    end
  end

  routes do
    post :enqueue_crawl, on: :member
  end
end
