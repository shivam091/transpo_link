# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :warehouse_manager, class: "Warehouse::Manager" do
    association :warehouse
    association :manager, factory: :manager
  end
end
