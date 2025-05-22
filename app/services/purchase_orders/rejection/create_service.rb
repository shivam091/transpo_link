# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::Rejection::CreateService < ApplicationService
  def initialize(purchase_order, rejection_attributes)
    @purchase_order, @rejection_attributes = purchase_order, rejection_attributes
  end

  def call
    create_rejection_record
  end

  private

  attr_reader :purchase_order, :rejection_attributes

  def create_rejection_record
    rejection = purchase_order.build_rejection(rejection_attributes)

    if rejection.save
      ServiceResponse.success(payload: {rejection:})
    else
      ServiceResponse.error(payload: {rejection:})
    end
  end
end
