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

  desc "Run all assessments for a local property in band"
  task :assess => :environment do
    property = Property.kept.for_purposeful_crawls.first
    production_group = Assessment::ProductionGroup.create!(
      property: property,
      account: property.account,
      reason: "dev",
      started_at: Time.now.utc,
    )

    Infrastructure::SynchronousQueJobs.with_synchronous_jobs do
      Crawl::KeyUrlsCrawlJob.run(property_id: property.id, production_group_id: production_group.id)
      Crawl::InteractionRunnerJob.enqueue(property_id: property.id, production_group_id: production_group.id, interaction_id: "shopify-browse-add")

      if property.shopify_shop.present?
        Assessment::AssessProductDataJob.enqueue(shopify_shop_id: property.shopify_shop.id, production_group_id: production_group.id)
      end
    end
  end

  desc "Run all data syncs for a local shopify shop in band"
  task :shopify_sync => :environment do
    shopify_shop = ShopifyShop.kept.first

    Infrastructure::SynchronousQueJobs.with_synchronous_jobs do
      ShopifyData::AllSyncJob.enqueue(shopify_shop_id: shopify_shop.id)
    end
  end
end
