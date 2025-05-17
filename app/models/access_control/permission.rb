# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessControl::Permission < ApplicationRecord
  validates :action_id,
            presence: true,
            uniqueness: {scope: :module_id},
            reduce: true
  validates :module_id, presence: true, reduce: true
  validates :position,
            presence: true,
            uniqueness: {scope: :module_id, message: :already_within_module},
            numericality: {only_integer: true, greater_than: 0},
            reduce: true

  has_many :role_permissions,
           class_name: "AccessControl::RolePermission",
           inverse_of: :permission,
           dependent: :restrict_with_exception
  has_many :roles, through: :role_permissions, source: :role

  with_options inverse_of: :permissions do |a|
    a.belongs_to :action, class_name: "AccessControl::Action"
    a.belongs_to :module, class_name: "AccessControl::Module"
  end
end
