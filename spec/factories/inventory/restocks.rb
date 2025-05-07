# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_restock, class: "Inventory::Restock" do
    association :inventory_batch
    note { Faker::Lorem.paragraph(sentence_count: 3) }
    comment { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end
