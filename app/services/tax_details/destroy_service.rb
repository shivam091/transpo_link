# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetails::DestroyService < ApplicationService
  def initialize(tax_detail)
    @tax_detail = tax_detail
  end

  def call
    destroy_tax_detail
  end

  private

  attr_reader :tax_detail

  def destroy_tax_detail
    if tax_detail.destroy
      ServiceResponse.success(message: t("tax_details.destroy.info"), payload: {tax_detail: tax_detail})
    else
      ServiceResponse.error(message: t("tax_details.destroy.alert"), payload: {tax_detail: tax_detail})
    end
  end
end
