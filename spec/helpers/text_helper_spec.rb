# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/text_helper_spec.rb

require "spec_helper"

RSpec.describe TextHelper, type: :helper do
  describe "#truncate" do
    let!(:long_text) { "This is a test string that is longer than thirty characters." }

    it "returns the same string if it's within the limit" do
      expect(helper.truncate("Short text", truncate_at: 20)).to eq("Short text")
    end

    it "truncates and appends omission when exceeding limit" do
      expect(helper.truncate("This is a long text", truncate_at: 10)).to eq("This is a ...")
    end

    it "allows custom omission strings" do
      expect(helper.truncate("This is a long text", truncate_at: 10, omission: "[...]")).to eq("This is a [...]")
    end

    it "handles an empty string gracefully" do
      expect(helper.truncate("", truncate_at: 5)).to eq("")
    end

    it "handles nil input gracefully" do
      expect { helper.truncate(nil, truncate_at: 5) }.to raise_error(NoMethodError)
    end

    it "does not truncate if truncate_at is equal to string length" do
      expect(helper.truncate("Exact length", truncate_at: 12)).to eq("Exact length")
    end

    it "truncates a string with spaces properly" do
      expect(helper.truncate("This is a test string", truncate_at: 14)).to eq("This is a test...")
    end

    it "handles very small truncate_at values" do
      expect(helper.truncate("Hello world", truncate_at: 3)).to eq("Hel...")
    end

    it "uses the default truncate_at value when not provided" do
      expect(helper.truncate(long_text)).to eq("This is a test string that is ...")
    end
  end
end
