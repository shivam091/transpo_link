# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module Currency
    extend self

    def formatted_currency(currency)
      currency_obj = Money::Currency.new(currency)

      "#{currency_obj.name} (#{currency_obj.symbol})"
    rescue Money::Currency::UnknownCurrency
      nil
    end

    def options_for_currencies
      Money::Currency.all.collect do |currency|
        [formatted_currency(currency), currency.id.upcase.to_s]
      end
    end
  end
end
