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
    sync = Infrastructure::AssessmentDescriptorSync.new
    attributes = begin
        sync.fetch_remote
      rescue RestClient::Exception
        sync.load_cache
      end
    sync.save_cache attributes
    sync.import attributes
  end
end
