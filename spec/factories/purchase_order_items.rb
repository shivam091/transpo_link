# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order_item do
    # unit_cost & currency will be set automatically from Product#cost_price & Product#currency, respectively.
    association :purchase_order
    association :product
    quantity { Faker::Number.between(from: 1, to: 100) }
    association :unit, factory: :litre_unit

    PurchaseOrderItem.statuses.keys.each do |status|
      trait status do
        status { PurchaseOrderItem.statuses[status] }
      end
    end
  end
end
