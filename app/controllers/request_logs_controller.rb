# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestLogsController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_request_log, only: :show

  # GET /request-logs
  def index
    @request_logs = RequestLog.includes(user: :user_detail)
    @request_logs, @pagination_metadata = @request_logs.paginate(page: params[:page])
  end

  # GET /request-logs/:id
  def show
    add_breadcrumb @request_log.uuid, request_log_path(@request_log)
  end

  private

  def set_request_log
    @request_log ||= RequestLog.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("request_logs.breadcrumb"), request_logs_path
  end
end
