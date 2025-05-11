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
  include ScaleEnforcer

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

  belongs_to :inventory_batch, inverse_of: :stock
end
