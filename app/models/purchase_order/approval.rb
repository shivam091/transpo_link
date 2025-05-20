# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder::Approval < ApplicationRecord
  include Sanitizable, NullifyIfBlank

  nullify_if_blank :remarks

  sanitize_attributes :reference_document, :remarks

  belongs_to :purchase_order, inverse_of: :approval
end
