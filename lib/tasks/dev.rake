# frozen_string_literal: true
namespace :dev do
  desc "Output environment variables from dev environment to run tests using"
  task :env_vars => :environment do
    SemanticLogger.default_level = :warn

    shop = ShopifyShop.kept.first

    env = {
      SHOPIFY_SHOP_OAUTH_DOMAIN: shop.myshopify_domain,
      SHOPIFY_SHOP_OAUTH_ACCESS_TOKEN: shop.api_token,
    }

    env.each do |key, value|
      if ENV.fetch("SHELL", "/bin/bash").ends_with?("fish")
        puts "set -x #{key} \"#{value}\";"
      else
        puts "export #{key}=\"#{value}\";"
      end
    end

    puts "Restarting spring"
    system "bin/spring", "stop"
    puts "Good to go!"
  end

  desc "Fetch and store descriptors"
  task :sync_descriptors => :environment do
    url = "https://scorpion-admin.gadget.dev/assessment/descriptors/dump"
    token = ENV.fetch("DEV_ACCESS_TOKEN")

    response = RestClient::Request.execute(
      method: :get,
      url: url,
      headers: { :Authorization => "Bearer #{token}", accept: :json },
    )

    existings = Assessment::Descriptor.all.to_a.index_by(&:key)
    passed = JSON.parse(response.body)
    passed.each do |blob|
      instance = existings[blob["key"]] || Assessment::Descriptor.new
      instance.assign_attributes(blob.except("id"))
      instance.save!
    end
  end
end
