# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitsController < ApplicationController
  before_action :set_breadcrumbs

  # GET /units
  def index
    @units = Unit.all
    @units, @pagination_metadata = @units.paginate(page: params[:page], per_page: 25)
  end

  private

  def set_breadcrumbs
    add_breadcrumb t("units.breadcrumb"), unit_conversions_path
  end
end
