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

  describe ".currency_options" do
    it "returns a collection of formatted currencies" do
      options = described_class.currency_options
      expect(options).to include("<option value=\"INR\">Indian Rupee (₹)</option>")
    end

    it "preselects the given currency" do
      options = described_class.currency_options("INR")
      expect(options).to include("<option selected=\"selected\" value=\"INR\">Indian Rupee (₹)</option>")
    end
  end
end
