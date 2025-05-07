# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :po_item_delivery, class: "PurchaseOrderItem::Delivery" do
    association :purchase_order_item
    quantity { 5.0 }
    note { Faker::Lorem.paragraph(sentence_count: 3) }
    comment { Faker::Lorem.paragraph(sentence_count: 3) }
    reference_document { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    unit { find_or_create_unit("item") }
  end
end
