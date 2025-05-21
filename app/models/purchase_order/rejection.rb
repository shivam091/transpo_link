# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder::Rejection < ApplicationRecord
  belongs_to :purchase_order, inverse_of: :rejection
end
