# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class DashboardsController < ApplicationController

  requires_authorization_for :show, :dashboards, :view

  # GET /
  def show
  end
end
