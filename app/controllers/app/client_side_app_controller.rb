# frozen_string_literal: true

class App::ClientSideAppController < AppAreaController
  include BaseClientSideAppSettings

  def index
    @settings = base_settings.merge(
      accountId: current_account.id,
      baseUrl: app_root_path(current_account),
      shopify: {
        apiKey: Rails.configuration.shopify.api_key,
        shopOrigin: @current_shop.domain,
      },
    )
  end
end
