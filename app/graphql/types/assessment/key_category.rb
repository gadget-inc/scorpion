# frozen_string_literal: true
class Types::Assessment::KeyCategory < Types::BaseEnum
  ::Assessment::Categories.each do |key, _details|
    value key.to_s.upcase, value: key.to_s, description: "Assessments concerning the #{key.to_s.titleize} area of a property"
  end
end
