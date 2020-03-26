# frozen_string_literal: true

module ShopifyData
  # Invokes lighthouse using the crawler service to find all the requests made fo third party JS on a given storefront.
  class AppDetector
    include SemanticLogger::Loggable
    include Wisper::Publisher

    LIGHTHOUSE_CONFIG = {
      extends: "lighthouse:default",
      settings: {
        onlyAudits: %w[
          network-requests
        ],
      },
    }.freeze

    attr_reader :shopify_shop

    def initialize(shopify_shop)
      @shopify_shop = shopify_shop
    end

    def detect
      results = []

      Crawl::CrawlerClient.client.lighthouse(
        @shopify_shop.property,
        @shopify_shop.property.key_urls.map(&:url),
        lighthouse_config: LIGHTHOUSE_CONFIG,
        trace_context: { purpose: "shopify-app-detector" },
        on_result: proc { |result| results << result["lighthouse"]["audits"]["network-requests"]["details"]["items"] },
        on_error: proc { |error_result| logger.warn("error encountered detecting apps with lighthouse", { error: error_result }) },
      )

      detect_apps(results.flatten)
      broadcast(:shopify_apps_changed, { shopify_shop_id: @shopify_shop.id, property_id: @shopify_shop.property_id })
    end

    def detect_apps(lighthouse_requests)
      @now = Time.now.utc

      detections = @shopify_shop.detected_apps.where(seen_last_time: true).each_with_object({}) do |detected_app, agg|
        agg[detected_app.name] = {
          record: detected_app,
          seen: false,
          urls: [],
        }
      end

      lighthouse_requests.filter { |request| request["resourceType"] == "Script" }.each do |request|
        entity = Infrastructure::ThirdPartyWeb.instance.entity(request["url"])
        unless entity
          logger.info("Unrecognized URL for app detection", { url: request["url"] })
        end
        next if entity[:name] == "Shopify"
        name = entity[:name]
        if detections.key?(name)
          detections[name][:seen] = true
          detections[name][:urls].push(request["url"])
        else
          detections[name] = {
            seen: true,
            record: @shopify_shop.detected_apps.build(account_id: @shopify_shop.account_id, name: name, first_seen_at: @now),
            urls: [request["url"]],
          }
        end
      end

      seen_detections, unseen_detections = detections.values.partition { |detection| detection[:seen] }
      seen_detections.each do |detection|
        mark_as_seen(detection[:record], detection[:urls])
      end

      unseen_detections.each do |detection|
        mark_as_unseen(detection[:record])
      end
    end

    private

    def mark_as_seen(detected_app, urls)
      DetectedApp.transaction do
        first_time = detected_app.new_record?
        detected_app.last_seen_at = @now
        detected_app.seen_last_time = true
        detected_app.reasons = urls.sort.map { |url| "Request made to #{url}" }
        detected_app.save!

        if first_time
          shopify_shop.detected_app_change_events.create!(account_id: @shopify_shop.account_id, detected_app: detected_app, action: "detected", action_at: @now)
        end
      end
    end

    def mark_as_unseen(detected_app)
      DetectedApp.transaction do
        if detected_app.new_record?
          raise "Processing error: can't unsee an ever before seen app"
        end
        detected_app.seen_last_time = false
        detected_app.save!

        shopify_shop.detected_app_change_events.create!(account_id: @shopify_shop.account_id, detected_app: detected_app, action: "no_longer_detected", action_at: @now)
      end
    end
  end
end
