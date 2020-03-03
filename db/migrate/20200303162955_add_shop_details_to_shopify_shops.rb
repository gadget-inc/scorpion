# frozen_string_literal: true
class AddShopDetailsToShopifyShops < ActiveRecord::Migration[6.0]
  def change
    change_table(:shopify_shops, bulk: true) do |t|
      t.string :myshopify_domain, null: false, default: "unknown"
      t.string :country_code
      t.string :country_name
      t.string :currency
      t.string :timezone
      t.string :customer_email
      t.string :source
      t.string :latitude
      t.string :longitude
      t.string :money_format
      t.string :money_with_currency_format
      t.string :cookie_consent_level
      t.boolean :password_enabled
      t.boolean :has_storefront
      t.boolean :multi_location_enabled
      t.boolean :setup_required
      t.boolean :pre_launch_enabled
      t.boolean :requires_extra_payments_agreement
      t.boolean :taxes_included
      t.boolean :tax_shipping
      t.string :enabled_presentment_currencies
      t.string :plan_name, null: false, default: "unknown"
      t.string :plan_display_name, null: false, default: "unknown"
      t.string :weight_unit
      t.datetime :shopify_updated_at
    end
  end
end
