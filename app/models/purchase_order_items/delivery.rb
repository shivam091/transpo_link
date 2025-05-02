# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::Delivery < ApplicationRecord
  self.table_name = :purchase_order_item_deliveries

  include ScaleEnforcer

  scale_attributes :quantity

  validates :quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id,
            presence: true,
            reduce: true

  belongs_to :purchase_order_item, inverse_of: :deliveries
  belongs_to :unit, inverse_of: :delivered_po_items
end
