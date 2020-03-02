# frozen_string_literal: true

class AppAreaController < ApplicationController
  include ShopifyAuthenticated
  layout "app_area_client_side_app"
end
