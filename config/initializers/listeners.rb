# frozen_string_literal: true
Rails.application.config.to_prepare do
  # this block is rerun every request in development so you don't have to restart the dev server to reset listeners
  Wisper.clear if Rails.env.development?
  Wisper.subscribe(Activity::FeedListener.new, prefix: :on)
end
