# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouses::CreateService < ApplicationService
  def initialize(warehouse_attributes)
    @warehouse_attributes = warehouse_attributes.dup
  end

  def call
    create_warehouse
  end

  private

  attr_reader :warehouse_attributes

  def create_warehouse
    warehouse = Warehouse.new(warehouse_attributes)
    if warehouse.save
      ServiceResponse.success(message: t("warehouses.create.notice"), payload: {warehouse: warehouse})
    else
      ServiceResponse.error(message: t("warehouses.create.alert"), payload: {warehouse: warehouse})
    end
  end
end
