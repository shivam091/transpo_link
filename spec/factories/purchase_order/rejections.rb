# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order_rejection, class: "PurchaseOrder::Rejection" do
    association :purchase_order
    reason { :item_out_of_stock }
    suggested_alternatives { Faker::Lorem.paragraph(sentence_count: 3) }
    note { Faker::Lorem.sentence(word_count: 50) }
  end
end
