# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitConversion < ApplicationRecord
  belongs_to :product, inverse_of: :unit_conversions
end
