# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order_approval, class: "PurchaseOrder::Approval" do
    association :purchase_order
    association :user, factory: :supplier
    reference_document { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    expected_delivery_date { Date.current + 1.month }
    incoterm_code { :exw }
    shipping_method { :air }
    payment_terms { Faker::Lorem.paragraph(sentence_count: 3) }
    remarks { Faker::Lorem.sentence(word_count: 50) }
    partial_delivery_allowed { true }
  end
end
