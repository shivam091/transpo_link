# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "ipinfo" unless defined?(IPinfo)

class IpInfo
  def initialize(app, cache_options = {})
    @app = app
    token = Rails.application.credentials.config[:IP_LOOKUP_API_KEY]
    @ipinfo = IPinfo.create(token, cache_options)
  end

  def call(env)
    env["ipinfo"] = @ipinfo.details.all
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
