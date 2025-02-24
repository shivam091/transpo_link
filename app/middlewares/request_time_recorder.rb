# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestTimeRecorder
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    env["REQUEST_STARTED_AT"] = Time.now.utc
    @app.call(env)
  end
end
