# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestLogsController < ApplicationController

  before_action :find_request_log, only: :show

  # GET /request-logs
  def index
    @request_logs = RequestLog.includes(user: :user_detail)
    @request_logs, @pagination_data = @request_logs.paginate(params[:page])
  end

  # GET /request-logs/:id
  def show
  end

  private

  def find_request_log
    @request_log = RequestLog.find(params[:id])
  end
end
