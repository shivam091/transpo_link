# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestLogsController < ApplicationController

  # GET /request-logs
  def index
    @request_logs = RequestLog.includes(user: :user_detail)
    @request_logs, @pagination_data = @request_logs.paginate(params[:page])
  end
end
