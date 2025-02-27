# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousePresenter < ApplicationPresenter
  include ActiveSupport::NumberHelper

  presents :warehouse

  def capacity
    "#{number_to_delimited(try(:total_capacity))} #{try(:capacity_unit)}".strip
  end

  def formatted_latitude
    [latitude, "°"].compact.join if latitude.present?
  end

  def formatted_longitude
    [longitude, "°"].compact.join if longitude.present?
  end
end
