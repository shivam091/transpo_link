# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder::Approval < ApplicationRecord
  include Sanitizable, NullifyIfBlank

  nullify_if_blank :remarks

  sanitize_attributes :reference_document, :remarks

  validates :reference_document,
            presence: true,
            length: {maximum: 55},
            reduce: true
  validates :expected_delivery_date,
            presence: true,
            comparison: {
              greater_than_or_equal_to: Date.current,
              message: :must_be_today_or_future_date
            },
            reduce: true
  validates :remarks,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  validate :expected_delivery_date_within_six_months

  belongs_to :purchase_order, inverse_of: :approval

  private

  def expected_delivery_date_within_six_months
    return if expected_delivery_date.blank?

    max_date = Date.current + 180.days

    if expected_delivery_date > max_date
      errors.add(:expected_delivery_date, :must_be_within_six_months)
    end
  end
end
