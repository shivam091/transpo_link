# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to provide shared functionalities for managing currency related
# logic.
module ActsAsMoney
  extend ActiveSupport::Concern

  included do
    validates :currency,
              presence: true,
              reduce: true

    def currency
      Money::Currency.new(self[:currency]) if self[:currency].present?
    end
  end
end
