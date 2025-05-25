# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder::CancellationRecord < ApplicationRecord
  include Sanitizable, NullifyIfBlank

  enum :reason, {
    stock_no_longer_required: "STOCK_NO_LONGER_REQUIRED",
    duplicate_order: "DUPLICATE_ORDER",
    pricing_issue: "PRICING_ISSUE",
    supplier_unresponsive: "SUPPLIER_UNRESPONSIVE",
    delayed_delivery_commitment: "DELAYED_DELIVERY_COMMITMENT",
    product_discontinued_or_unavailable: "PRODUCT_DISCONTINUED_OR_UNAVAILABLE",
    changed_sourcing_strategy: "CHANGED_SOURCING_STRATEGY",
    internal_error_or_mistake: "INTERNAL_ERROR_OR_MISTAKE",
    payment_or_budget_issue: "PAYMENT_OR_BUDGET_ISSUE",
    other: "OTHER",
    realized_an_input_error: "REALIZED_AN_INPUT_ERROR",
    urgent_need_fulfilled_through_alternate_means: "URGENT_NEED_FULFILLED_THROUGH_ALTERNATE_MEANS",
    merged_into_another_po: "MERGED_INTO_ANOTHER_PO",
    supplier_terms_changed_after_approval: "SUPPLIER_TERMS_CHANGED_AFTER_APPROVAL",
    stock_re_evaluated_after_internal_audit: "STOCK_RE_EVALUATED_AFTER_INTERNAL_AUDIT",
    partial_order_not_viable: "PARTIAL_ORDER_NOT_VIABLE",
    canceled_due_to_supplier_side_delay_pre_approval: "CANCELED_DUE_TO_SUPPLIER_SIDE_DELAY_PRE_APPROVAL"
  }

  nullify_if_blank :note

  sanitize_attributes :note

  belongs_to :cancellable, polymorphic: true, inverse_of: :cancellation_record
  belongs_to :user, inverse_of: :cancellation_records
end
