# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# == Statuses definitions
#
# available: Stock is in the batch and can be used for orders.
# reserved: Stock is allocated but not yet consumed (e.g., QA hold, future order).
# partially_used: Some stock from the batch has been consumed.
# exhausted: All usable stock has been consumed, batch is depleted.
# locked: Batch is locked manually or due to error/dispute.
# damaged: Entire batch or major part is damaged/unusable.
# closed: Batch is finalized or archived — no further actions allowed.

class InventoryBatch::Stock < ApplicationRecord
  include AASM, ScaleEnforcer

  enum :status, {
    available: "available",
    reserved: "reserved",
    partially_used: "partially_used",
    exhausted: "exhausted",
    locked: "locked",
    damaged: "damaged",
    closed: "closed"
  }

  attribute :used_quantity, default: 0.0
  attribute :status, default: statuses[:available]

  scale_attributes :ordered_quantity, :reserved_quantity, :damaged_quantity,
                   :returned_quantity, :restocked_quantity, :restockable_quantity,
                   :available_quantity, :used_quantity

  aasm column: :status, enum: true, requires_lock: true do
    state :available, initial: true
    state :reserved, :partially_used, :exhausted, :locked, :damaged, :closed

    event :reserve do
      transitions from: :available, to: :reserved
    end

    event :consume_partially do
      transitions from: [:available, :reserved], to: :partially_used
    end

    event :consume_fully do
      transitions from: [:available, :reserved, :partially_used], to: :exhausted
    end

    event :lock do
      transitions from: [:available, :reserved, :partially_used, :exhausted], to: :locked
    end

    event :damage do
      transitions from: [:available, :reserved], to: :damaged
    end

    event :close do
      transitions from: [:exhausted, :locked], to: :closed
    end
  end

  belongs_to :inventory_batch, inverse_of: :stock

  before_save :recalculate_quantities, :auto_update_status
  before_update :prevent_updates_if_locked

  private

  def recalculate_quantities
    batch_qty = inventory_batch&.quantity.to_d

    self.restockable_quantity = batch_qty - restocked_quantity
    self.available_quantity = batch_qty - used_quantity
  end

  def auto_update_status
    return if locked? # don't override locked status

    if is_locked? && may_lock?
      lock
    elsif fully_consumed? && may_consume_fully?
      consume_fully
    elsif partially_consumed? && may_consume_partially?
      consume_partially
    elsif exhausted? && may_close?
      close
    else
      self.status = :available
    end
  end

  def prevent_updates_if_locked
    return unless is_locked_changed? && is_locked?

    if ordered_quantity_changed? || reserved_quantity_changed?
      errors.add(:base, :cannot_modify_locked_batch)

      throw :abort
    end
  end

  def fully_consumed?
    available_quantity.to_f <= 0.0
  end

  def partially_consumed?
    ordered_quantity.to_f > 0.0 || reserved_quantity.to_f > 0.0
  end

  def exhausted?
    fully_consumed? && used_quantity.to_f >= inventory_batch.quantity.to_f
  end
end
