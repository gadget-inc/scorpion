# frozen_string_literal: true
# Implements a handy thing for making only-sort-of-sensitive API endpoints accessible to developers for syncing stuff
module Infrastructure::TrustedDeveloperAuth
  def require_trusted_developer
    return render_unauthorized if request.headers["Authorization"].blank?
    token = request.headers["Authorization"].split(" ").last
    return render_unauthorized if token != Rails.configuration.dev_infrastructure[:api_access_token]
  end

  def render_unauthorized
    render plain: "Unauthorized", status: :unauthorized
  end
end
