# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessControl::RolePermission < ApplicationRecord
  with_options inverse_of: :role_permissions do |a|
    a.belongs_to :role
    a.belongs_to :permission, class_name: "AccessControl::Permission"
  end
end
