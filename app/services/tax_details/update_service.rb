# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetails::UpdateService < ApplicationService
  def initialize(tax_detail, tax_detail_attributes)
    @tax_detail, @tax_detail_attributes = tax_detail, tax_detail_attributes
  end

  def call
    update_tax_detail
  end

  private

  attr_reader :tax_detail, :tax_detail_attributes

  def update_tax_detail
    if tax_detail.update(tax_detail_attributes)
      ServiceResponse.success(message: t("tax_details.update.notice"), payload: {tax_detail: tax_detail})
    else
      ServiceResponse.error(message: t("tax_details.update.alert"), payload: {tax_detail: tax_detail})
    end
  end
end
