# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: false -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/utils_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::Utils do
  describe ".safe_downcase!" do
    context "when the string is not frozen" do
      it "downcases the string in place" do
        str = "HeLLo"
        result = described_class.safe_downcase!(str)
        expect(result).to eq("hello")
        expect(str).to eq("hello")
      end

      it "returns the original string if it is already lowercase" do
        str = "hello"
        result = described_class.safe_downcase!(str)
        expect(result).to eq("hello")
        expect(str).to eq("hello")
      end
    end

    context "when the string is frozen" do
      it "returns a downcased copy of the string" do
        str = "HeLLo".freeze
        result = described_class.safe_downcase!(str)
        expect(result).to eq("hello")
        expect(str).to eq("HeLLo") # Original string remains unchanged
      end

      it "returns the original string if it is already lowercase" do
        str = "hello".freeze
        result = described_class.safe_downcase!(str)
        expect(result).to eq("hello")
        expect(str).to eq("hello") # Original string remains unchanged
      end
    end

    context "edge cases" do
      it "handles empty strings" do
        str = ""
        result = described_class.safe_downcase!(str)
        expect(result).to eq("")
      end

      it "handles strings with no alphabetic characters" do
        str = "1234!@#"
        result = described_class.safe_downcase!(str)
        expect(result).to eq("1234!@#")
      end
    end
  end
end
