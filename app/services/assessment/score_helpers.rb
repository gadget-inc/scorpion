# frozen_string_literal: true

# Helpers for producing scores for assessments
module Assessment::ScoreHelpers
  def ratio_score(decimal)
    clamp_score((decimal * 100).round)
  end

  def clamp_score(score)
    score.clamp(0, 100)
  end
end
