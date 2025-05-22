# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumPoRejectionReasons < ActiveRecord::Migration[8.0]
  def change
    create_enum :po_rejection_reasons, %i[
      ITEM_OUT_OF_STOCK
      ITEM_DISCONTINUED
      MINIMUM_ORDER_NOT_MET
      LEAD_TIME_TOO_SHORT
      INVALID_SHIPPING_LOCATION
      PAYMENT_TERMS_UNACCEPTABLE
      PRICING_DISAGREEMENT
      CAPACITY_CONSTRAINTS
      PACKAGING_REQUIREMENTS_UNMET
      COMPLIANCE_DOCUMENTS_MISSING
      SEASONAL_ITEM_UNAVAILABLE
      WRONG_SPECIFICATIONS
      LOGISTICS_UNAVAILABLE
      MANUAL_ERROR
      ALREADY_FULFILLED_BY_OTHER
      CONTRACT_TERMS_VIOLATED
    ]
  end
end
