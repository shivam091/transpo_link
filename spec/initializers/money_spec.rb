# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/money_spec.rb

require "spec_helper"

RSpec.describe "Money configuration for TranspoLink" do
  def load_initializers
    load Rails.root.join("config/initializers/money.rb")
  end

  before do
    load_initializers
  end

  describe "default currency" do
    it "sets the default currency" do
      expect(Money.default_currency).to eq(Money::Currency.new("INR"))
    end
  end
end
