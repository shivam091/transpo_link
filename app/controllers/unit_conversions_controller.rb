# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitConversionsController < ApplicationController
  before_action :set_breadcrumbs

  # GET /unit-conversions
  def index
    @unit_conversions = UnitConversion.includes(:source_unit, :target_unit)
    @unit_conversions, @pagination_metadata = @unit_conversions.paginate(page: params[:page])
  end

  private

  def set_breadcrumbs
    add_breadcrumb t("unit_conversions.breadcrumb"), unit_conversions_path
  end
end
