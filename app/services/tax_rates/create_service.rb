# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRates::CreateService < ApplicationService
  def initialize(tax_rate_attributes)
    @tax_rate_attributes = tax_rate_attributes
  end

  def call
    create_tax_rate
  end

  private

  attr_reader :tax_rate_attributes

  def create_tax_rate
    tax_rate = TaxRate.new(tax_rate_attributes)

    if tax_rate.save
      ServiceResponse.success(payload: {tax_rate:})
    else
      ServiceResponse.error(payload: {tax_rate:})
    end
  end
end
