# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousePresenter < ApplicationPresenter
  include NumberHelper

  presents :warehouse

  def capacity
    "#{number_to_delimited(try(:total_capacity))} #{try(:capacity_unit)}".strip
  end

  def formatted_latitude
    number_to_angle(try(:latitude))
  end

  def formatted_longitude
    number_to_angle(try(:longitude))
  end
end
