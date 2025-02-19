# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousePresenter < ApplicationPresenter
  include ActiveSupport::NumberHelper

  presents :warehouse

  def capacity
    [number_to_delimited(try(:total_capacity)), try(:capacity_unit)].compact.join(" ")
  end
end
