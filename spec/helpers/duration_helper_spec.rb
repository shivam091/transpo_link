# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/duration_helper_spec.rb

require "spec_helper"

RSpec.describe DurationHelper, type: :helper do
  describe "#prettify_seconds" do
    it "returns formatted duration for seconds" do
      expect(helper.prettify_seconds(45)).to eq("45 seconds")
    end

    it "returns formatted duration for minutes and seconds" do
      expect(helper.prettify_seconds(90)).to eq("1 minute and 30 seconds")
    end

    it "returns formatted duration for hours, minutes, and seconds" do
      expect(helper.prettify_seconds(5_445)).to eq("1 hour, 30 minutes, and 45 seconds")
    end

    it "returns formatted duration for days, hours, minutes, and seconds" do
      expect(helper.prettify_seconds(90_000)).to eq("1 day and 1 hour")
    end

    it "returns formatted duration for weeks and days" do
      expect(helper.prettify_seconds(1_296_000)).to eq("2 weeks and 1 day")
    end

    it "returns formatted duration for months, weeks, and days" do
      expect(helper.prettify_seconds(13_104_000)).to eq("4 months, 4 weeks, 1 day, 22 hours, 3 minutes, and 36 seconds")
    end

    it "returns formatted duration for years, months, and weeks" do
      expect(helper.prettify_seconds(63_072_000)).to eq("1 year, 11 months, 4 weeks, 1 day, 22 hours, 50 minutes, and 42 seconds")
    end

    it "returns an empty string for zero seconds" do
      expect(helper.prettify_seconds(0)).to eq("0 seconds")
    end

    context "when providing a custom locale and scope" do
      let(:custom_locale) { :es }
      let(:custom_scope) { "custom.datetime.units" }
      let(:options) { {locale: custom_locale, scope: custom_scope} }

      it "uses the provided locale and scope" do
        expect(I18n).to receive(:with_options).with(**options).and_call_original

        helper.prettify_seconds(3600, options)
      end
    end
  end
end
