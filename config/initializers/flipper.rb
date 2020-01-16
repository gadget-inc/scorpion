# frozen_string_literal: true

Flipper.register(:staff) do |actor|
  actor.respond_to?(:internal_tags) && actor.internal_tags.include?("staff")
end
