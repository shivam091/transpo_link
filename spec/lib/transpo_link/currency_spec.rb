# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/currency_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::Currency do
  describe ".formatted_currency" do
    it "returns formatted currency string" do
      expect(described_class.formatted_currency("INR")).to eq("Indian Rupee (₹)")
      expect(described_class.formatted_currency("EUR")).to eq("Euro (€)")
    end

    it "returns the nil if the currency is invalid" do
      expect(described_class.formatted_currency("XYZ")).to be_nil
    end
  end

  describe ".options_for_currencies" do
    it "returns a collection of formatted currencies" do
      expect(described_class.options_for_currencies).to include(["Indian Rupee (₹)", "INR"])
    end
  end
end
