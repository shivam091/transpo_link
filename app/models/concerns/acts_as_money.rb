# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module ActsAsMoney
  extend ActiveSupport::Concern

  included do
    def currency
      Money::Currency.new(self[:currency])
    end
  end
end
