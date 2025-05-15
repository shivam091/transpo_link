# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :access_control_role_permission, class: "AccessControl::RolePermission", aliases: [:role_permission] do
    association :role, factory: :admin_role
    association :permission, factory: :permission
  end
end
