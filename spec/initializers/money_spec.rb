# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/money_spec.rb

require "spec_helper"

RSpec.describe "Money configuration for TranspoLink" do
  before { load_file("config/initializers/money.rb") }

  describe "default currency" do
    it "sets the default currency" do
      expect(Money.default_currency).to eq(Money::Currency.new("INR"))
    end
  end
end
