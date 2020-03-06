# frozen_string_literal: true

# Attribute type for allowing Rails' parameters to be assigned to a JSONB column and property decoded/encoded
# Use like so:
#  class SomeModel
#    attribute :internal_test_options, JsonbTypeValue.new
#  end
class JsonbTypeValue < ActiveModel::Type::Value
  def type
    :jsonb
  end

  # rubocop:disable Style/RescueModifier
  def cast_value(value)
    case value
    when String
      ActiveSupport::JSON.decode(value) rescue nil
    when Hash
      value
    end
  end

  # rubocop:enable Style/RescueModifier

  def serialize(value)
    case value
    when Hash
      ActiveSupport::JSON.encode(value)
    else
      super
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    cast_value(raw_old_value) != new_value
  end
end
