# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRates::DestroyService < ApplicationService
  def initialize(tax_rate)
    @tax_rate = tax_rate
  end

  def call
    destroy_tax_rate
  end

  private

  attr_reader :tax_rate

  def destroy_tax_rate
    if tax_rate.destroy
      ServiceResponse.success(payload: {tax_rate:})
    else
      ServiceResponse.error(payload: {tax_rate:})
    end
  end
end
