# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/date_time_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::DateTime do
  before do
    I18n.backend.store_translations(:en, {
      date: {
        formats: {
          default: "%Y-%m-%d",
          short: "%d %b",
          long: "%B %d, %Y",
          long_with_day: "%a, %B %d, %Y",
          long_with_hyphen: "%F",
          year_and_month: "%Y-%m",
        }
      },
      time: {
        formats: {
          twelve_hours_long: "%I:%M:%S %p",
          twelve_hours_short: "%I:%M %p",
          twenty_four_hours_short: "%H:%M",
          twenty_four_hours_long: "%T",
          default_twelve_hours: "%d %b %Y, %I:%M %p",
          default_twenty_four_hours: "%d %b %Y, %H:%M",
          short: "%d %b %H:%M",
          short_with_seconds: "%d %b %H:%M:%S",
          long: "%B %d, %Y %H:%M",
          long_with_seconds: "%B %d, %Y %H:%M:%S",
          twelve_hours_long_with_gmt_zone: "%B %d, %Y %I:%M:%S %p GMT%z",
          twenty_four_hours_long_with_gmt_zone: "%B %d, %Y %H:%M:%S GMT%z",
          twelve_hours_default_with_gmt_zone: "%d %b %Y, %I:%M:%S %p GMT%z",
          twenty_four_hours_default_with_gmt_zone: "%d %b %Y, %H:%M:%S GMT%z",
          twelve_hours_long_with_local_zone: "%B %d, %Y %I:%M:%S %p %Z",
          twenty_four_hours_long_with_local_zone: "%B %d, %Y %H:%M:%S %Z",
          twelve_hours_default_with_local_zone: "%d %b %Y, %I:%M:%S %p %Z",
          twenty_four_hours_default_with_local_zone: "%d %b %Y, %H:%M:%S %Z"
        }
      }
    })
  end

  it { is_expected.to have_constant(:DATE_FORMATS) }
  it { is_expected.to have_constant(:TIME_FORMATS) }
  it { is_expected.to have_constant(:DATE_TIME_FORMATS) }

  describe ".date_format_options" do
    let(:options) { described_class.date_format_options }

    it "returns formatted date strings for each date format" do
      expect(options.keys).to match_array(%i[default short long long_with_day long_with_hyphen year_and_month])
      expect(options.values).to all(be_a(String))
    end
  end

  describe ".time_format_options" do
    let(:options) { described_class.time_format_options }

    it "returns formatted time strings for each time format" do
      expect(options.keys).to match_array(%i[twelve_hours_long twelve_hours_short twenty_four_hours_short twenty_four_hours_long])
      expect(options.values).to all(be_a(String))
    end
  end

  describe ".date_time_format_options" do
    let(:options) { described_class.date_time_format_options }

    it "returns formatted datetime strings for each datetime format" do
      expect(options.keys).to include(:default_twelve_hours, :long_with_seconds, :twenty_four_hours_default_with_local_zone)
      expect(options.values).to all(be_a(String))
    end
  end

  describe ".date_format_select_options" do
    let(:options) { described_class.date_format_select_options }

    it "returns an array of [label, key] pairs for select inputs" do
      expect(options).to all(be_an(Array))
      expect(options).to all(satisfy { |item| item.size == 2 && item[1].is_a?(Symbol) })
    end
  end

  describe ".time_format_select_options" do
    let(:options) { described_class.time_format_select_options }

    it "returns an array of [label, key] pairs for select inputs" do
      expect(options).to all(be_an(Array))
      expect(options).to all(satisfy { |item| item.size == 2 && item[1].is_a?(Symbol) })
    end
  end

  describe ".date_time_format_select_options" do
    let(:options) { described_class.date_time_format_select_options }

    it "returns an array of [label, key] pairs for select inputs" do
      expect(options).to all(be_an(Array))
      expect(options).to all(satisfy { |item| item.size == 2 && item[1].is_a?(Symbol) })
    end
  end
end
