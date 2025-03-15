# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitConversion < ApplicationRecord
  include Sortable

  LISTING_ATTRIBUTES = %i[from_unit to_unit conversion_rate].freeze

  belongs_to :product, inverse_of: :unit_conversions, touch: true

  default_scope { order_created_desc }
end
