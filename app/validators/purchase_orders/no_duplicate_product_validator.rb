# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::NoDuplicateProductValidator < ActiveModel::Validator
  def validate(record)
    return if record.marked_for_destruction?
    return unless (purchase_order = record.purchase_order)
    return unless purchase_order.purchase_order_items.loaded?

    # Find the first non-destroyed item with the same product_id
    first_match = purchase_order.purchase_order_items.find do |item|
      !item.marked_for_destruction? && item.product_id == record.product_id
    end

    # If there's a match, and it's not this record, then it's a duplicate
    if first_match && first_match != record && record.product_id == first_match.product_id
      record.errors.add(:product_id, :duplicate_in_order)
    end
  end
end
