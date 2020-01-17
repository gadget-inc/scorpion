# frozen_string_literal: true

class Crawler::CrawlerClient
  include SemanticLogger::Loggable

  class UncleanExitException < RuntimeError; end

  def self.client
    @client ||= self.new(Rails.configuration.crawler[:api_url], Rails.configuration.crawler[:auth_token])
  end

  def initialize(base_api_url, auth_token)
    @base_url = base_api_url
    @auth_token = auth_token
  end

  def block_until_available
    logger.debug("Checking for crawler service availability ...", uri: @base_url)
    Infrastructure::ServiceAvailability.block_until_available(@base_url, timeout: 120)
  end

  def crawl(property, **args)
    request("/crawl", {
      property: property_blob(property),
    }, **args)
  end

  def screenshots(property, pages, **args)
    request("/screenshots", {
      property: property_blob(property),
      pages: pages,
    }, **args)
  end

  def lighthouse(property, pages, **args)
    request("/lighthouse", {
      property: property_blob(property),
      pages: pages,
    }, **args)
  end

  def text_blocks(property, **args)
    request("/text_blocks", {
      property: property_blob(property),
    }, **args)
  end

  protected

  def property_blob(property)
    {
      id: property.id.to_s,
      crawlRoots: property.crawl_roots,
      allowedDomains: property.allowed_domains,
    }
  end

  def request(method, payload, on_result:, on_error:, on_log: nil, trace_context: nil, crawl_options: nil)
    got_success_message = false
    trace_context ||= {}
    crawl_options ||= {}

    RestClient::Request.execute(
      method: :post,
      url: @base_url + method,
      payload: {
        traceContext: trace_context,
        crawlOptions: crawl_options,
      }.merge!(payload).to_json,
      headers: { :Authorization => "Bearer #{@auth_token}", content_type: :json },
      read_timeout: nil,
      block_response: proc { |response|
        Infrastructure::LineWiseHttpResponseReader.new(response).each_line do |line|
          blob = JSON.parse(line)

          if blob["tag"] == "crawl_result"
            on_result.call(blob["result"])
          end

          if blob["tag"] == "crawl_error"
            on_error.call(blob)
          end

          if blob["tag"] == "log" && !on_log.nil?
            on_log.call(blob.except("tag"))
          end

          if blob["tag"] == "system_error"
            raise UncleanExitException, "Crawl errored out! Remote error: #{blob["message"]}"
          end

          if blob["tag"] == "system"
            if !blob["success"].nil? && !blob["success"]
              error = blob["error"]
              if error.respond_to?(:key?) && error.key?("message")
                error = error["message"]
              end
              raise UncleanExitException, "Crawl did not succeed! Remote error: #{error || "unknown"}"
            else
              got_success_message = true
            end
          end
        end
      },
    )

    if !got_success_message
      raise UncleanExitException, "Crawler response ended prematurely without signalling success"
    end
  end
end
