# frozen_string_literal: true
module Identity
  # Given a url we discovered on a crawl, figure out where assessments on that URL should go in the UI
  class UrlCategorizer
    def initialize(property)
      @property = property
    end

    def categorize(_url)
      # TODO: implement
      # will likey need to be able to accept information from the ShopifyMeta object in the JS context there too
      :home
    end
  end
end
