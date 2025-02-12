# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/country_info_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::CountryInfo do
  let(:country_code) { "IN" }
  let(:subdivision_code) { "MH" }
  let(:country_info) { described_class.new(country_code, subdivision_code) }

  describe "#country" do
    it "returns the country object for the given code" do
      expect(country_info.country).to be_a(ISO3166::Country)
      expect(country_info.country.alpha2).to eq(country_code)
    end
  end

  describe "#subdivision" do
    context "when subdivision code is present" do
      it "returns the subdivision object" do
        expect(country_info.subdivision).to be_present
        expect(country_info.subdivision.code).to eq(subdivision_code)
      end
    end

    context "when subdivision code is nil" do
      let(:subdivision_code) { nil }

      it "returns nil" do
        expect(country_info.subdivision).to be_nil
      end
    end
  end

  describe "#country_name" do
    context "when country translation exists" do
      it "returns the translated country name" do
        I18n.with_locale(:en) do
          expect(country_info.country_name).to eq("India")
        end
      end
    end

    context "when country translation is missing" do
      it "falls back to the country alpha2" do
        allow(country_info.country).to receive(:translations).and_return({})
        expect(country_info.country_name).to eq("IN")
      end
    end
  end

  describe "#subdivision_name" do
    context "when subdivision translation exists" do
      it "returns the translated subdivision name" do
        I18n.with_locale(:en) do
          expect(country_info.subdivision_name).to eq("Maharashtra")
        end
      end
    end

    context "when subdivision translation is missing" do
      it "falls back to the subdivision name" do
        allow(country_info.subdivision).to receive(:translations).and_return({})
        expect(country_info.subdivision_name).to eq("Maharashtra")
      end
    end

    context "when subdivision is nil" do
      let(:subdivision_code) { nil }

      it "returns nil" do
        expect(country_info.subdivision_name).to be_nil
      end
    end
  end

  describe "#options_for_subdivisions" do
    context "when country has subdivisions" do
      it "returns an array of subdivision options for select" do
        I18n.with_locale(:en) do
          options = country_info.options_for_subdivisions
          expect(options).to include(["Maharashtra", "MH"])
        end
      end
    end

    context "when country has no subdivisions" do
      let(:country_code) { "VA" } # Vatican City has no subdivisions

      it "returns an empty array" do
        expect(country_info.options_for_subdivisions).to be_empty
      end
    end
  end

  describe ".options_for_countries" do
    it "returns an array of country options for select" do
      I18n.with_locale(:es) do
        options = described_class.options_for_countries
        expect(options).to include(["India", "IN"])
      end
    end
  end
end
