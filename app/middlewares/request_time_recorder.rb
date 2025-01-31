# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestTimeRecorder
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    env["REQUEST_STARTED_AT"] = Time.now.utc
    status, headers, response = @app.call(env)

    [status, headers, response]
  end
end
