# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder::Rejection < ApplicationRecord
  include Sanitizable, NullifyIfBlank

  enum :reason, {
    item_out_of_stock: "ITEM_OUT_OF_STOCK",
    item_discontinued: "ITEM_DISCONTINUED",
    minimum_order_not_met: "MINIMUM_ORDER_NOT_MET",
    lead_time_too_short: "LEAD_TIME_TOO_SHORT",
    invalid_shipping_location: "INVALID_SHIPPING_LOCATION",
    payment_terms_unacceptable: "PAYMENT_TERMS_UNACCEPTABLE",
    pricing_disagreement: "PRICING_DISAGREEMENT",
    capacity_constraints: "CAPACITY_CONSTRAINTS",
    packaging_requirements_unmet: "PACKAGING_REQUIREMENTS_UNMET",
    compliance_documents_missing: "COMPLIANCE_DOCUMENTS_MISSING",
    seasonal_item_unavailable: "SEASONAL_ITEM_UNAVAILABLE",
    wrong_specifications: "WRONG_SPECIFICATIONS",
    logistics_unavailable: "LOGISTICS_UNAVAILABLE",
    manual_error: "MANUAL_ERROR",
    already_fulfilled_by_other: "ALREADY_FULFILLED_BY_OTHER",
    contract_terms_violated: "CONTRACT_TERMS_VIOLATED",
  }

  nullify_if_blank :suggested_alternatives, :note

  sanitize_attributes :suggested_alternatives, :note

  validates :reason,
            presence: true,
            inclusion: {in: reasons.keys, message: :inclusion},
            reduce: true
  validates :suggested_alternatives,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true
  validates :note,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  belongs_to :purchase_order, inverse_of: :rejection
  belongs_to :user, inverse_of: :rejected_purchase_orders

  after_create :reject_purchase_order!

  private

  def reject_purchase_order!
    PurchaseOrders::RejectService.(purchase_order)
  end
end
