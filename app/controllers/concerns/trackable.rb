# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module for tracking reuest information.
module Trackable
  extend ActiveSupport::Concern

  included do
    around_action :log_activity
  end

  private

  def log_activity
    @request_log = RequestLog.new(
      uuid: request.uuid,
      uri: "#{request.protocol}#{request.host_with_port}#{request.path}",
      method: request.request_method,
      session_id: request.session.id.to_s,
      session_private_id: request.session.id&.private_id.to_s,
      remote_address: IPAddr.new(request.remote_ip),
      user_agent: request.user_agent,
      referrer: request.referrer,
      query_params: request.filtered_parameters.except(:controller, :action),
      ip_info: request.env["ipinfo"],
      user: current_user
    )
    yield
  rescue StandardError => exception
    request.env["rack.exception"] = exception
    raise exception
  ensure
    exception = request.env["rack.exception"]

    @request_log.assign_attributes(
      exception_message: exception&.message,
      elapsed_time: (Time.now.utc - request.env["REQUEST_STARTED_AT"]),
      response_size: (response.body&.bytesize || 0),
      status: (exception ? http_status_for(exception) : (response&.status || 500))
    )
    @request_log.save!
  end

  def http_status_for(exception)
    case exception
    when ActiveRecord::RecordNotFound, ActionController::RoutingError then 404
    when ActionController::InvalidAuthenticityToken                   then 403
    else                                                                   500
    end
  end
end
