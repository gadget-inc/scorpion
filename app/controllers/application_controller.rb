# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :wrap_with_unit_of_work
  after_action :track_server_side_page_view

  attr_reader :current_user, :current_account

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def trusted_dev_request?
    (Rails.env.development? || Rails.env.integration_test?) && request.headers["HTTP_X_TRUSTED_DEV_CLIENT"].present?
  end

  def wrap_with_unit_of_work
    Infrastructure::UnitOfWork.unit("#{controller_name}##{action_name}") do |unit|
      unit.add_tags(client_session_id: client_session_id)

      if current_user.present?
        Raven.user_context(user_id: current_user.id, email: current_user.email)
        Honeycomb.add_field("user_id", current_user.id)
      end

      current_account = respond_to?(:current_account) && current_account.present?
      if current_account
        unit.add_tags(account_id: current_account.id, account_name: current_account.name)
      end

      yield
    end
  end

  def track_server_side_page_view
    if current_user.present?
      Analytics.track(
        user_id: current_user.id,
        event: "Request Made",
        properties: {
          account_id: respond_to?(:current_account) && current_account.id,
          request_id: request.request_id,
          client_session_id: client_session_id,
        },
      )
    end
  end

  def client_session_id
    request.headers["X-Client-Session-Id"]
  end

  def require_no_signed_in_user
    if current_user.present?
      render status: :forbidden, json: { error: "Already signed in as a user, this action is forbidden" }
    end
  end

  def flipper_flag_enabled?(flag)
    account_enabled = respond_to?(:current_account) && current_account && Flipper[flag].enabled?(current_account)
    user_enabled = respond_to?(:current_user) && current_user && Flipper[flag].enabled?(current_user)
    account_enabled || user_enabled
  end
end
