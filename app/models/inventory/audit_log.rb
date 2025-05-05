# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory::AuditLog < ApplicationRecord
  self.inheritance_column = :_type_disabled

  include Sortable

  LISTING_ATTRIBUTES = %i[user_id type previous_quantity new_quantity].freeze

  belongs_to :inventory, inverse_of: :audit_logs
  belongs_to :movement, class_name: "Inventory::Movement", inverse_of: :audit_logs, optional: true
  belongs_to :user, inverse_of: :inventory_audit_logs

  before_validation :set_default_attributes

  default_scope { order_created_desc }

  private

  def set_default_attributes
    self.user = Current.user
  end
end
