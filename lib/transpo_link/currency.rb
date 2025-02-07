# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module Currency
    extend self

    include ActionView::Helpers::FormOptionsHelper

    def formatted_currency(currency)
      currency_obj = Money::Currency.new(currency)

      "#{currency_obj.name} (#{currency_obj.symbol})"
    rescue Money::Currency::UnknownCurrency
      nil
    end

    def currency_options(selected_currency = nil)
      options_for_select(
        Money::Currency.all.collect do |currency|
          [formatted_currency(currency), currency.id.upcase.to_s]
        end,
        selected_currency
      )
    end
  end
end
