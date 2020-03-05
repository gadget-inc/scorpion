# frozen_string_literal: true

# Customized session store class for the shopify_app gem that uses our own models to manage Shopify providers in the context of accounts that don't necessarily need to be tied right to Shopify.
# Based on https://github.com/Shopify/shopify_app/blob/master/lib/shopify_app/session/session_storage.rb which is usually included right into the Shop model by ShopifyApp::SessionStorage
module Infrastructure::ShopifyUserSessionRepository
  def self.store(auth_session, blob)
    identity = UserProviderIdentity.kept.find_or_initialize_by(provider_name: "shopify", provider_id: blob[:user][:id])
    if identity.new_record?
      user = User.create!(
        email: blob[:user][:email],
        full_name: "#{blob[:user][:first_name]} #{blob[:user][:last_name]}",
      )
      identity.user_id = user.id
      identity
    end

    identity.provider_details["shopify_token"] = auth_session.token
    identity.provider_details["shopify_domain"] = auth_session.domain
    identity.save!
    identity
  end

  def self.retrieve(id)
    return unless id
    if (identity = UserProviderIdentity.kept.find_by(provider_name: "shopify", provider_id: id))
      session_for_identity(identity)
    end
  end

  def self.retrieve_with_context(id)
    return unless id
    if (identity = UserProviderIdentity.kept.find_by(provider_name: "shopify", provider_id: id))
      {
        api_session: session_for_identity(identity),
        identity: identity,
        user: identity.user,
      }
    end
  end

  def self.session_for_identity(identity)
    ShopifyAPI::Session.new(
      domain: identity.provider_details["shopify_domain"],
      token: identity.provider_details["shopify_token"],
      api_version: ShopifyApp.configuration.api_version,
    )
  end
end
