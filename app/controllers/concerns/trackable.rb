# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module for tracking reuest information.
module Trackable
  extend ActiveSupport::Concern

  included do
    after_action :log_activity
  end

  private

  def log_activity
    log_data = {
      uuid: request.uuid,
      uri: request.url,
      method: request.request_method,
      session_id: request.session.id.to_s,
      session_private_id: request.session.id&.private_id.to_s,
      remote_address: IPAddr.new(request.remote_ip),
      elapsed_time: (Time.now.utc - request.env["REQUEST_STARTED_AT"]),
      user_agent: request.user_agent,
      referrer: request.referrer,
      exception_message: request.env["rack.exception"]&.message,
      status: response.status,
      response_size: response.body.bytesize,
      query_params: request.filtered_parameters.except(:controller, :action),
      ip_info: request.env["ipinfo"],
      user: current_user
    }
    RequestLog.create!(log_data)
  rescue StandardError => e
    Rails.logger.error("Failed to log request: #{e.message}")
  end
end
