# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/application_helper_spec.rb

require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#currencies" do
    it "returns an array of currency name and symbol pairs" do
      currencies = helper.currencies

      expect(currencies).to be_an(Array)
      expect(currencies).not_to be_empty

      # Check if first element is an array with expected format
      first_currency = currencies.first
      expect(first_currency).to be_an(Array)
      expect(first_currency.size).to eq(2)

      # Example currency verification (USD should be present)
      usd_currency = currencies.find { |c| c[1] == "USD" }
      expect(usd_currency).not_to be_nil
      expect(usd_currency[0]).to include("Dollar")
      expect(usd_currency[0]).to include("$")
    end

    it "includes known currencies" do
      currency_ids = helper.currencies.map(&:last)
      expect(currency_ids).to include("USD", "EUR", "GBP", "JPY")
    end
  end

end
