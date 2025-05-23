# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class StockAdjustment < ApplicationRecord
  belongs_to :adjustable, inverse_of: :stock_adjustments, polymorphic: true
  belongs_to :source, inverse_of: :stock_adjustments, polymorphic: true, optional: true
  belongs_to :inventory, inverse_of: :stock_adjustments, optional: true
  belongs_to :user, inverse_of: :stock_adjustments
  belongs_to :unit, inverse_of: :stock_adjustments
end
