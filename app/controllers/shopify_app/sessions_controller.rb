# frozen_string_literal: true

module ShopifyApp
  class SessionsController < ApplicationController
    include ShopifyApp::LoginProtection

    layout false, only: :new
    after_action only: %i[new create] do |controller|
      controller.response.headers.except!("X-Frame-Options")
    end

    def new
      authenticate if sanitized_shop_name.present?
    end

    def create
      authenticate
    end

    def enable_cookies
      return unless validate_shop

      render(:enable_cookies, layout: false, locals: {
                                does_not_have_storage_access_url: top_level_interaction_path(
                                  shop: sanitized_shop_name,
                                  return_to: params[:return_to],
                                ),
                                has_storage_access_url: login_url_with_optional_shop(top_level: true),
                                app_target_url: granted_storage_access_path(
                                  shop: sanitized_shop_name,
                                  return_to: params[:return_to],
                                ),
                                current_shopify_domain: current_shopify_domain,
                              })
    end

    def top_level_interaction
      @url = login_url_with_optional_shop(top_level: true)
      validate_shop
    end

    def granted_storage_access
      return unless validate_shop

      session["shopify.granted_storage_access"] = true

      copy_return_to_param_to_session

      redirect_to(return_address_with_params({ shop: @shop }))
    end

    def destroy
      reset_session
      flash[:notice] = I18n.t(".logged_out")
      redirect_to(login_url_with_optional_shop)
    end

    private

    def authenticate
      return render_invalid_shop_error if sanitized_shop_name.blank?
      session["shopify.omniauth_params"] = { shop: sanitized_shop_name }

      copy_return_to_param_to_session

      if user_agent_can_partition_cookies
        authenticate_with_partitioning
      else
        authenticate_normally
      end
    end

    def authenticate_normally
      if request_storage_access?
        redirect_to_request_storage_access
      elsif authenticate_in_context?
        authenticate_in_context
      else
        authenticate_at_top_level
      end
    end

    def authenticate_with_partitioning
      if session["shopify.cookies_persist"]
        clear_top_level_oauth_cookie
        authenticate_in_context
      else
        set_top_level_oauth_cookie
        enable_cookie_access
      end
    end

    def validate_shop
      @shop = sanitized_shop_name
      unless @shop
        render_invalid_shop_error
        return false
      end

      true
    end

    def copy_return_to_param_to_session
      session[:return_to] = params[:return_to] if params[:return_to]
    end

    def render_invalid_shop_error
      flash[:error] = I18n.t("invalid_shop_url")
      redirect_to return_address
    end

    def enable_cookie_access
      fullpage_redirect_to(enable_cookies_path(
        shop: sanitized_shop_name,
        return_to: session[:return_to],
      ))
    end

    def authenticate_in_context
      shopify_domain = (sanitized_shop_name || session[:shopify_domain])
      url = if shopify_domain && ShopifyShop.kept.where(myshopify_domain: shopify_domain).first
          "/auth/shopify"
        else
          "/auth/shopify_offline"
        end

      redirect_to url
    end

    def authenticate_at_top_level
      fullpage_redirect_to(login_url_with_optional_shop(top_level: true))
    end

    def authenticate_in_context?
      return true unless ShopifyApp.configuration.embedded_app?
      params[:top_level]
    end

    def request_storage_access?
      return false unless ShopifyApp.configuration.embedded_app?
      return false if params[:top_level]
      return false if user_agent_is_mobile
      return false if user_agent_is_pos

      !session["shopify.granted_storage_access"]
    end

    def redirect_to_request_storage_access
      render(
        :request_storage_access,
        layout: false,
        locals: {
          does_not_have_storage_access_url: top_level_interaction_path(
            shop: sanitized_shop_name,
            return_to: session[:return_to],
          ),
          has_storage_access_url: login_url_with_optional_shop(top_level: true),
          app_target_url: granted_storage_access_path(
            shop: sanitized_shop_name,
            return_to: session[:return_to],
          ),
          current_shopify_domain: current_shopify_domain,
        },
      )
    end
  end
end
