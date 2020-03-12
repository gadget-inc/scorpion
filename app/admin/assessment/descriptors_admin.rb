# frozen_string_literal: true
Trestle.resource(:descriptors, scope: Assessment) do
  menu do
    group :assessment, priority: 10 do
      item :descriptors, icon: "fa fa-file-alt"
    end
  end

  table do
    column :id
    column :key
    column :severity
    column :title
    column :created_at, align: :center
    column :updated_at, align: :center
    actions
  end

  form do |descriptor|
    if descriptor.new_record?
      text_field :key
    else
      static_field :key
    end

    text_field :title
    select :severity, Assessment::Descriptor.severities

    editor :description

    row do
      col { static_field :updated_at }
      col { static_field :created_at }
    end
  end
end
