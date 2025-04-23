# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Replenishments::CreateService < ApplicationService
  def initialize(inventory)
    @inventory = inventory
  end

  def call
    create_replenishment
  end

  private

  attr_reader :inventory

  def create_replenishment
    Replenishment.create!(inventory:)
  end
end
