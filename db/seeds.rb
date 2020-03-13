# frozen_string_literal: true

require "factory_bot_rails"
require "faker"
Rails.logger = ActiveSupport::Logger.new(STDOUT)
Rails.logger.info("Starting seed")

user = User.new(full_name: "Smart Developer", email: "dev@gadget.dev", internal_tags: ["staff"])
user.save!

FactoryBot.create :account, creator: user

# Enable all feature flags for developers
BaseClientSideAppSettings::EXPORTED_FLAGS.each do |flag|
  Flipper[flag].enable
end

Rails.logger.info "DB Seeded!"
[Account, User, Property, Assessment::Descriptor].each do |klass|
  Rails.logger.info "#{klass.name} count: #{klass.all.count}"
end
