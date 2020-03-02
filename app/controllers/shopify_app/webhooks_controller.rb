# frozen_string_literal: true
module ShopifyApp
  class WebhooksController < ApplicationController
    include ShopifyApp::WebhookVerification

    class ShopifyApp::MissingWebhookJobError < StandardError; end

    def receive
      params.permit!
      job_args = { shop_domain: shop_domain, webhook: webhook_params.to_h }
      if webhook_job_klass == ShopifyData::SyncEventsJob
        job_args.delete(:webhook)
      end
      webhook_job_klass.enqueue(job_args) # modified to use que job signature
      head :no_content
    end

    private

    def webhook_params
      params.except(:controller, :action, :type)
    end

    def webhook_job_klass
      webhook_job_klass_name.safe_constantize || raise(ShopifyApp::MissingWebhookJobError)
    end

    def webhook_job_klass_name(type = webhook_type)
      [webhook_namespace, "#{type}_job"].compact.join("/").classify
    end

    def webhook_type
      params[:type]
    end

    def webhook_namespace
      ShopifyApp.configuration.webhook_jobs_namespace
    end
  end
end
