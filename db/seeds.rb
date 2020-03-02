# frozen_string_literal: true

require "factory_bot_rails"
require "faker"
Rails.logger = ActiveSupport::Logger.new(STDOUT)
Rails.logger.info("Starting seed")

user = User.new(full_name: "Smart Developer", email: "dev@gadget.dev", internal_tags: ["staff"])
user.skip_confirmation!
user.save!

account = FactoryBot.create :account, creator: user
account.properties.create!(name: "Sole Destroyer", creator: user, allowed_domains: ["sole-destroyer.myshopify.com"], crawl_roots: ["https://sole-destroyer.myshopify.com"])

# Enable all feature flags for developers
BaseClientSideAppSettings::EXPORTED_FLAGS.each do |flag|
  Flipper[flag].enable
end

Rails.logger.info "DB Seeded!"
[Account, User].each do |klass|
  Rails.logger.info "#{klass.name} count: #{klass.all.count}"
end
