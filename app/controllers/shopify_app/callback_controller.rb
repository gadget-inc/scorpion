# frozen_string_literal: true

module ShopifyApp
  # Performs login after OAuth completes
  class CallbackController < ApplicationController
    include ShopifyApp::LoginProtection

    def offline_callback
      session[:stored_shop_auth_hash] = request.env["omniauth.auth"]
      redirect_to "/auth/shopify"
    end

    def callback
      if auth_hash
        login_shop
        install_webhooks
        install_scripttags
        perform_after_authenticate_job

        redirect_to return_address
      else
        flash[:error] = I18n.t("could_not_log_in")
        redirect_to(login_url_with_optional_shop)
      end
    end

    private

    def login_shop
      reset_session_options
      set_shopify_session
    end

    def auth_hash
      request.env["omniauth.auth"]
    end

    def shop_name
      auth_hash.uid
    end

    def associated_user
      return if auth_hash["extra"].blank?

      auth_hash["extra"]["associated_user"]
    end

    def token
      auth_hash["credentials"]["token"]
    end

    def reset_session_options
      request.session_options[:renew] = true
      session.delete(:_csrf_token)
    end

    def set_shopify_session
      session_store = ShopifyAPI::Session.new(
        domain: shop_name,
        token: token,
        api_version: ShopifyApp.configuration.api_version,
      )
      session[:shopify] = ShopifyApp::SessionRepository.store(session_store, user: associated_user)
      session[:shopify_domain] = shop_name
      session[:shopify_user] = associated_user

      # Adds the user_session to the session to determine if the logged in user has changed
      user_session = auth_hash&.extra&.session
      raise IndexError, "Missing user session signature" if user_session.nil?
      session[:user_session] = user_session

      if session[:stored_shop_auth_hash]
        sign_up = Identity::ShopifySignUp.new
        sign_up.create_account_if_necessary!(session[:shopify], session[:stored_shop_auth_hash])
        session.delete(:stored_shop_auth_hash)
      end
    end

    def install_webhooks
      return unless ShopifyApp.configuration.has_webhooks?

      WebhooksManager.queue(
        shop_name,
        token,
        ShopifyApp.configuration.webhooks
      )
    end

    def install_scripttags
      return unless ShopifyApp.configuration.has_scripttags?

      ScripttagsManager.queue(
        shop_name,
        token,
        ShopifyApp.configuration.scripttags
      )
    end

    def perform_after_authenticate_job
      config = ShopifyApp.configuration.after_authenticate_job

      return unless config && config[:job].present?

      job = config[:job]
      job = job.constantize if job.is_a?(String)

      if config[:inline] == true
        job.perform_now(shop_domain: session[:shopify_domain])
      else
        job.perform_later(shop_domain: session[:shopify_domain])
      end
    end
  end
end
