# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessControl::RolePermission < ApplicationRecord
  validates :role_id,
            presence: true,
            uniqueness: {scope: :permission_id},
            reduce: true
  validates :permission_id, presence: true, reduce: true

  with_options inverse_of: :role_permissions do |a|
    a.belongs_to :role, touch: true
    a.belongs_to :permission, class_name: "AccessControl::Permission"
  end

  scope :ordered_by_positions, -> do
    modules = AccessControl::Module.arel_table
    permissions = AccessControl::Permission.arel_table

    joins(permission: :module)
      .includes(permission: [:module, :action])
      .order(modules[:position].asc, permissions[:position].asc)
  end

  after_commit :invalidate_cache

  delegate :module, :action, to: :permission

  class << self
    def grouped_by_module
      all.group_by { |role_permission| role_permission.permission.module }
    end
  end

  private

  def invalidate_cache
    Rails.cache.delete(["user_permissions", role_id])
  end
end
