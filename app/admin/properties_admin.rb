# frozen_string_literal: true

Trestle.resource(:properties) do
  menu do
    item :properties, icon: "fa fa-boxes"
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
  form do |property|
    tab :results, badge: property.crawl_attempts.size do
      table property.crawl_attempts.order("started_at DESC"), admin: :crawl_attempts do
        column :id
        column :started_at, link: true
        column :started_reason
        column :running, align: :center
        column :succeeded, align: :center
        column :failure_reason
        actions
      end
    end

    tab :property do
      text_field :name
      select :crawl_roots, nil, {}, multiple: true, data: { tags: true, select_on_close: true }
      select :allowed_domains, nil, {}, multiple: true, data: { tags: true, select_on_close: true }
    end

    sidebar do
      link_to("Crawl now", admin.path(:crawl, id: property.id), method: :post, class: "btn btn-block btn-primary")
    end
  end

  controller do
    def crawl
      property = admin.find_instance(params)
      Crawler::ExecuteCrawl.run_in_background(property, "admin trigger")
      flash[:message] = "Property crawl enqueued"
      redirect_to admin.path(:show, id: property)
    end
  end

  routes do
    post :crawl, on: :member
  end
end
