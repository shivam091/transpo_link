# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :access_control_permission, class: "AccessControl::Permission", aliases: [:permission] do
    association :action, factory: :action
    association :module, factory: :module
  end
end
