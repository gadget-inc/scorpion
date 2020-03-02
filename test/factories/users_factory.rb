# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:full_name) { |n| "Joe Bloweth The #{n}" }
    sequence(:email) { |n| "person#{n}@example.com" }

    factory :cypress_user do
      email { "cypress@gadget.dev" }
      full_name { "Cypress Test User" }
    end
  end
end
