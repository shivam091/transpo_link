# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetails::CreateService < ApplicationService
  def initialize(user, tax_detail_attributes)
    @user, @tax_detail_attributes = user, tax_detail_attributes
  end

  def call
    create_tax_detail
  end

  private

  attr_reader :user, :tax_detail_attributes

  def create_tax_detail
    tax_detail = user.tax_details.build(tax_detail_attributes)
    if tax_detail.save
      ServiceResponse.success(message: t("tax_details.create.notice"), payload: {tax_detail: tax_detail})
    else
      ServiceResponse.error(message: t("tax_details.create.alert"), payload: {tax_detail: tax_detail})
    end
  end
end
