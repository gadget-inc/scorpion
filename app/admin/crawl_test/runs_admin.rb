# frozen_string_literal: true
Trestle.resource(:runs, scope: CrawlTest) do
  menu do
    group :crawl_testing, priority: 50 do
      item :runs, icon: "fa fa-star"
    end
  end

  # Customize the table columns shown on the index view.
  #
  # table do
  #   column :name
  #   column :created_at, align: :center
  #   actions
  # end

  form do |run|
    if run.new_record?
      text_field :name
      text_field :endpoint

      row do
        col(sm: 6) do
          text_field :property_criteria
        end
        col(sm: 6) do
          text_field :property_limit
        end
      end
    else
      tab :results, badge: run.crawl_test_cases.size do
        table run.crawl_test_cases.includes(:property).order("started_at DESC"), admin: :crawl_test_cases do
          column :property, link: true
          column :started_at, link: true
          column :finished_at
          column :running, align: :center
          column :successful, align: :center
          actions do |toolbar, instance, _admin|
            toolbar.link "Logs", admin_url_for(instance, anchor: "!tab-logs"), style: :primary, icon: "fa fa-scroll"
          end
        end
      end

      tab :details do
        text_field :name, disabled: true
        text_field :endpoint, disabled: true
        text_field :started_by, disabled: true
      end
    end
  end

  build_instance do |attrs, _params|
    instance = CrawlTest::Run.new(attrs)
    instance.name ||= CrawlTest::Tester.generate_name
    instance.endpoint ||= "/interaction/shopify_browse_add"
    instance.property_limit ||= 50
    instance
  end

  controller do
    def create
      # Use our service object instead of trestle to create the object
      created_instance = CrawlTest::Tester.new.enqueue_run(
        name: instance.name,
        endpoint: instance.endpoint,
        user: current_user["info"]["email"],
        property_limit: instance.property_limit,
        property_criteria: params[:property_criteria],
      )

      respond_to do |format|
        format.html do
          flash[:message] = flash_message("create.success", title: "Success!", message: "The test run was successfully created and started.")
          redirect_to_return_location(:create, created_instance, default: admin.instance_path(created_instance))
        end
        format.json { render json: created_instance, status: :created, location: admin.instance_path(created_instance) }
      end
    end

    def logs
      @instance = admin.find_instance(params)
    end
  end
end
