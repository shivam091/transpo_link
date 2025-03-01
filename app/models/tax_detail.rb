# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetail < ApplicationRecord
  include Sortable, Pageable, Taxable

  normalizes :tax_number, with: -> tax_number { tax_number.strip.upcase }

  validates :user_id,
            presence: true,
            reduce: true
  validates :tax_number,
            presence: true,
            uniqueness: {scope: [:tax_type, :country], message: :uniqueness},
            reduce: true

  belongs_to :user, inverse_of: :tax_details, touch: true

  default_scope -> { order_created_desc }

  class << self
    def accessible(user)
      user.tax_details
    end
  end
end
