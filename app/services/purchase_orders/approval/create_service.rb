# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::Approval::CreateService < ApplicationService
  def initialize(purchase_order, approval_attributes)
    @purchase_order, @approval_attributes = purchase_order, approval_attributes
  end

  def call
    create_approval_record
  end

  private

  attr_reader :purchase_order, :approval_attributes

  def create_approval_record
    approval = purchase_order.build_approval(approval_attributes)

    if approval.save
      ServiceResponse.success(payload: {approval:})
    else
      ServiceResponse.error(payload: {approval:})
    end
  end
end
