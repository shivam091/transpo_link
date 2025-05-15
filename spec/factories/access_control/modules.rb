# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :access_control_module, class: "AccessControl::Module", aliases: [:module] do
    sequence(:label_key) { |n| "module_label_#{n}" }
  end
end
