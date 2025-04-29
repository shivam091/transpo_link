# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatchProcessingLog < ApplicationRecord
  enum :status, {
    pending: "pending",
    processing: "processing",
    succeeded: "succeeded",
    failed: "failed"
  }

  attribute :status, :enum, default: InventoryBatchProcessingLog.statuses[:pending]

  validates :error_message,
            length: {maximum: 2000},
            allow_blank: true,
            reduce: true
  validates :status,
            presence: true,
            reduce: true

  with_options inverse_of: :inventory_batch_processing_logs do |a|
    a.belongs_to :inventory_batch
    a.belongs_to :user
  end
end
