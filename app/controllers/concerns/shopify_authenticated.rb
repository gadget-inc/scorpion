# frozen_string_literal: true

module ShopifyAuthenticated
  extend ActiveSupport::Concern
  include ShopifyApp::Localization
  include ShopifyApp::LoginProtection
  include ShopifyApp::EmbeddedApp

  included do
    before_action :login_again_if_different_user_or_shop
    around_action :shopify_session
  end

  attr_reader :current_user
  attr_reader :current_account
  attr_reader :current_shop

  def shopify_session
    return redirect_to_login unless shop_session
    clear_top_level_oauth_cookie

    begin
      ShopifyAPI::Base.activate_session(shop_session)
      yield
    ensure
      ShopifyAPI::Base.clear_session
    end
  end

  def shop_session
    return unless session[:shopify_user]

    if !@shop_session
      details = Infrastructure::ShopifyUserSessionRepository.retrieve_with_context(session[:shopify_user]["id"])

      @current_user = details[:user]

      # Someday we will support account switching, in which case this will all have to be multi-account/multishop aware and depend on something set in the session saying which account we're looking at. Instead, we just infer it all from the account the Shopify user is set up to use
      @shop_session = details[:api_session]
      @current_provider_identity = details[:identity]
      @current_account = @current_user.permissioned_accounts.first
      @current_shop = ShopifyShop.where(account_id: @current_account.id).first
    end

    @shop_session
  end
end
