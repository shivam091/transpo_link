# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Stocks::CreateService < ApplicationService
  def initialize(inventory)
    @inventory = inventory
  end

  def call
    create_stock
  end

  private

  attr_reader :inventory

  def create_stock
    Stock.create!(inventory:)
  end
end
