# frozen_string_literal: true

module Infrastructure

  # Uses entities database from third-party-web NPM module to get the details of the entity owning a domain
  # Ruby port of https://github.com/patrickhulce/third-party-web/blob/3e6e9082c6f6969b38b07ded9971314a55a19a1e/lib/create-entity-finder-api.js
  class ThirdPartyWeb
    include Singleton

    DOMAIN_IN_URL_REGEX = %r{://(\S*?)(:\d+)?(/|$)}.freeze
    DOMAIN_CHARACTERS = /([a-z0-9.-]+\.[a-z0-9]+|localhost)/i.freeze
    IP_REGEX = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.freeze
    ROOT_DOMAIN_REGEX = /[^.]+\.([^.]+|(gov|com|co|ne)\.\w{2})$/i.freeze

    def initialize
      entities = JSON.parse(File.read(Rails.root.join("node_modules", "third-party-web", "dist", "entities.json"))) + JSON.parse(File.read(Rails.root.join("db", "third_party_web_extensions.json")))
      @entities_by_domain = {}
      @entities_by_root_domain = {}

      entities.each do |entity|
        entity = entity.with_indifferent_access
        entity[:company] ||= entity[:name]
        entity[:domains].each do |domain|
          @entities_by_domain[domain] = entity
          if domain.start_with?("*.")
            @entities_by_root_domain[root_domain(domain)] = entity
          end
        end
      end
    end

    def entity(origin_or_url)
      domain = domain_from_origin_or_url(origin_or_url)
      root = root_domain(domain)
      return nil unless domain || root
      @entities_by_domain[domain] || @entities_by_root_domain[root]
    end

    def root_domain(origin_or_url)
      domain = domain_from_origin_or_url(origin_or_url)
      return nil unless domain

      return domain if domain.match(IP_REGEX)

      if (match = domain.match(ROOT_DOMAIN_REGEX))
        return match[0]
      end

      domain
    end

    private

    def domain_from_origin_or_url(origin_or_url)
      return nil if origin_or_url.size > 10000 || origin_or_url.start_with?("data:")

      if (match = origin_or_url.match(DOMAIN_IN_URL_REGEX))
        return match[1]
      end

      if (match = origin_or_url.match(DOMAIN_CHARACTERS))
        return match[0]
      end

      raise "Unable to get domain from #{origin_or_url}"
    end
  end
end
