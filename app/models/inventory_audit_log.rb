# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryAuditLog < ApplicationRecord
  include Sortable

  LISTING_ATTRIBUTES = %i[user_id movement_type previous_quantity new_quantity].freeze

  with_options inverse_of: :inventory_audit_logs do |a|
    a.belongs_to :inventory
    a.belongs_to :inventory_movement, optional: true
    a.belongs_to :user
  end

  before_validation :set_default_attributes

  default_scope { order_created_desc }

  private

  def set_default_attributes
    self.user = Current.user
  end
end
