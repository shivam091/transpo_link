# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    [status, headers, response]
  rescue StandardError => exception
    env["rack.exception"] = exception
    raise exception
  ensure
    log_request(env, status, headers, response)
  end

  private

  def log_request(env, status, headers, response)
    request = ActionDispatch::Request.new(env)
    exception = request.env["rack.exception"]

    log_data = {
      uuid: request.uuid,
      uri: request.original_url,
      method: request.request_method,
      session_id: request.session.id.to_s,
      session_private_id: request.session.id&.private_id.to_s,
      remote_address: IPAddr.new(request.remote_ip),
      user_agent: request.user_agent,
      referrer: request.referrer,
      origin: (request.origin || request.referrer),
      query_params: request.filtered_parameters.except(:controller, :action),
      ip_info: request.env["ipinfo"],
      user: request.env["warden"]&.user(:user),
      exception: format_exception_response(exception),
      request_headers: filter_headers(env),
      response_headers: headers,
      elapsed_time: (Time.now.utc - env["REQUEST_STARTED_AT"]),
      response_size: response_size(response),
      memory_usage: memory_usage,
      cpu_usage: cpu_usage,
      status: (status || http_status_for(exception))
    }

    RequestLog.create!(log_data)
  rescue => e
    Rails.logger.error("Failed to log request: #{e.message}")
  end

  def http_status_for(exception)
    case exception
    when ActiveRecord::RecordNotFound, ActionController::RoutingError then 404
    when ActionController::InvalidAuthenticityToken                   then 403
    when ActiveRecord::RecordInvalid                                  then 422
    when Exception                                                    then 500
    else                                                                   200
    end
  end

  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i
  end

  def cpu_usage
    `ps -o %cpu= -p #{Process.pid}`.to_f
  end

  def response_size(response)
    response_body(response).bytesize || 0
  end

  def response_body(response)
    if response.respond_to?(:body)
      response.body.is_a?(Array) ? response.body.join : response.body
    elsif response.is_a?(Array) # Rack-style response [status, headers, body]
      response.map(&:to_s).join
    else
      response.inspect
    end
  end

  def format_exception_response(exception)
    {
      error: exception&.class.to_s,
      message: exception&.message,
      backtrace: exception&.backtrace&.take(5) # Limiting backtrace for security
    }
  end

  def filter_headers(env)
    env.select { |k, _| k.start_with?("HTTP_") }
       .transform_keys { |key| key.sub(/^HTTP_/, "").titleize.gsub(" ", "-") }
       .except("Authorization", "Cookie")
  end
end
