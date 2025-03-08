# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouses::UpdateService < ApplicationService
  def initialize(warehouse, warehouse_attributes)
    @warehouse, @warehouse_attributes = warehouse, warehouse_attributes
  end

  def call
    update_warehouse
  end

  private

  attr_reader :warehouse, :warehouse_attributes

  def update_warehouse
    if warehouse.update(warehouse_attributes)
      ServiceResponse.success(payload: {warehouse:})
    else
      ServiceResponse.error(payload: {warehouse:})
    end
  end
end
