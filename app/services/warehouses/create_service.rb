# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouses::CreateService < ApplicationService
  def initialize(warehouse_attributes)
    @warehouse_attributes = warehouse_attributes
  end

  def call
    create_warehouse
  end

  private

  attr_reader :warehouse_attributes

  def create_warehouse
    warehouse = Warehouse.new(warehouse_attributes)

    if warehouse.save
      ServiceResponse.success(payload: {warehouse:})
    else
      ServiceResponse.error(payload: {warehouse:})
    end
  end
end
