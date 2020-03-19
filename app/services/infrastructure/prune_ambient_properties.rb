# frozen_string_literal: true
module Infrastructure
  # Ambient properties are imported from big lists from the internet. Keep them up to date by running this prune-er to only keep alive ones that are shopify in the list.
  class PruneAmbientProperties
    include SemanticLogger::Loggable

    def run
      Property.for_ambient_crawls.order("id").find_each do |property|
        prune_unless_shopify property
      end
    end

    def prune_unless_shopify(property)
      logger.tagged({ property_id: property.id }) do
        is_shopify = nil
        begin
          url = property.crawl_roots[0]
          logger.info "Checking property", { url: url }
          response = RestClient.get(url)
          is_shopify = response.headers[:x_shopid].present?
        rescue RestClient::RequestFailed, SocketError, Errno::ECONNREFUSED => e
          is_shopify = false
          logger.warn("Error checking property", { message: e.message })
        end

        if !is_shopify
          logger.info "Discarding non-shopify property"
          property.discard!
        end
      end
    end
  end
end
