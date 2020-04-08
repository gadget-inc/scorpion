# frozen_string_literal: true
RestClient.log = SemanticLogger[RestClient]

# Instrumentation patch to add Sentry breadcrumbs and Honeycomb spans to HTTP requests made with rest-client
module RestClientInstrumentation
  def execute(*args, **kwargs)
    Honeycomb.start_span(name: "slow_operation") do |span|
      span.add_field("request_path", kwargs[:path])
      response = super
      record_sentry_breadcrumb(kwargs, response)
      record_honeycomb_span_result(span, response)
      response
    rescue RestClient::ExceptionWithResponse => e
      record_sentry_breadcrumb(kwargs, e.response)
      record_honeycomb_span_result(span, e.response)
      raise e
    end
  end

  def record_honeycomb_span_result(span, response)
    span.add_field("response_code", response.code)
  end

  def record_sentry_breadcrumb(kwargs, response)
    Raven.breadcrumbs.record do |crumb|
      headers = if response.is_a?(RestClient::Response)
          response.headers
        else
          {}
        end

      crumb.data = { response_code: response.try(&:code), response_headers: headers, response_class: response.class.name }
      crumb.category = "http-request"
      crumb.timestamp = Time.now.to_i
      crumb.message = "request to #{kwargs[:path]}"
    end
  end
end

RestClient::Request.singleton_class.prepend(RestClientInstrumentation)
