# frozen_string_literal: true
require "test_helper"

class DataModel::WarehouseIntrospectionTest < ActiveSupport::TestCase
  setup do
    @account = stub(id: 10)
  end

  test "it introspects the superpro wwarehouse" do
    introspection = DataModel::WarehouseIntrospection.new(@account, SuperproWarehouse).as_json

    assert introspection[:fact_tables].any? { |table_blob| table_blob[:name] == "Sales::OrderFacts" }
  end
end
