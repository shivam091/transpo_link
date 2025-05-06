# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::Deliveries::CreateService < ApplicationService
  def initialize(purchase_order_item, delivery_attributes)
    @purchase_order_item = purchase_order_item
    @delivery_attributes = delivery_attributes
  end

  def call
    create_delivery
  end

  private

  attr_reader :purchase_order_item, :delivery_attributes

  def create_delivery
    delivery = purchase_order_item.deliveries.build(delivery_attributes)

    if delivery.save
      ServiceResponse.success(payload: {delivery:})
    else
      ServiceResponse.error(payload: {delivery:})
    end
  end
end
