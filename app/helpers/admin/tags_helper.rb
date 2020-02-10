# frozen_string_literal: true

module Admin
  module TagsHelper
    def outcome_tag(outcome)
      if outcome == true
        status_tag(icon("fa fa-check"), :success)
      elsif outcome == false
        status_tag(icon("fa fa-times"), :danger)
      else
        content_tag(:span, "unknown", class: "blank")
      end
    end

    def running_tag(running)
      if running
        status_tag(icon("fa fa-running"), :info)
      else
        content_tag(:span, "no", class: "blank")
      end
    end
  end
end
