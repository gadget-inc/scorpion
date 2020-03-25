# frozen_string_literal: true
require "test_helper"

class Infrastructure::ReinstallAllWebhooksJobTest < ActiveJob::TestCase
  setup do
    @shop = create(:live_test_myshopify_shop)
  end

  test "it reinstalls script tags for the shop" do
    test_webhook = "https://#{Rails.configuration.x.domains.webhooks}/shopify/webhooks/example"

    @shop.with_shopify_session do
      ShopifyAPI::Webhook.all.to_a.each do |webhook|
        ShopifyAPI::Webhook.delete(webhook.id)
      end
      ShopifyAPI::Webhook.create(address: test_webhook, topic: "app/uninstalled")
      addresses = ShopifyAPI::Webhook.all.map(&:address)
      assert_includes addresses, test_webhook
    end

    with_synchronous_jobs do
      Infrastructure::ReinstallAllWebhooksJob.run
    end

    @shop.with_shopify_session do
      addresses = ShopifyAPI::Webhook.all.map(&:address)
      assert_not_includes addresses, test_webhook
      assert_not addresses.empty?
    end
  end
end
