# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :po_item_delivery, class: "PurchaseOrderItems::Delivery" do
    association :purchase_order_item
    quantity { 5.0 }
    unit { find_or_create_unit("item") }
  end
end
