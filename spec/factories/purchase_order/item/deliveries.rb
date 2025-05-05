# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :po_item_delivery, class: "PurchaseOrder::Item::Delivery" do
    association :item, factory: :purchase_order_item
    quantity { 5.0 }
    unit { find_or_create_unit("item") }
  end
end
