# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouses::DestroyService < ApplicationService
  def initialize(warehouse)
    @warehouse = warehouse
  end

  def call
    destroy_warehouse
  end

  private

  attr_reader :warehouse

  def destroy_warehouse
    if warehouse.destroy
      ServiceResponse.success(payload: {warehouse:})
    else
      ServiceResponse.error(payload: {warehouse:})
    end
  end
end
