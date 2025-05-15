# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :access_control_action, class: "AccessControl::Action", aliases: [:action] do
    sequence(:label_key) { |n| "action_label_#{n}" }
  end
end
