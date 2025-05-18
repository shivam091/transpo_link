# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Role < ApplicationRecord
  include Toggleable

  LISTING_ATTRIBUTES = %i[name is_active].freeze

  validates :name,
            presence: true,
            length: {in: 2..55},
            uniqueness: true,
            reduce: true

  has_many :users, inverse_of: :role, dependent: :restrict_with_exception
  has_many :role_permissions, class_name: "AccessControl::RolePermission", inverse_of: :role, dependent: :restrict_with_exception
  has_many :permissions, through: :role_permissions, class_name: "AccessControl::Permission"

  accepts_nested_attributes_for :role_permissions, allow_destroy: false
end
