# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/date_time_helper_spec.rb

require "spec_helper"

RSpec.describe DateTimeHelper, type: :helper do
  describe "#time_ago" do
    let(:now) { Time.zone.now }

    before do
      allow(I18n).to receive(:t).and_call_original
    end

    context "when time difference is in seconds" do
      it "returns just now" do
        expect(helper.time_ago(now - 0.seconds)).to eq("just now")
      end

      it "returns about a second ago" do
        expect(helper.time_ago(now - 1.second)).to eq("about a second ago")
      end

      it "returns about x seconds ago" do
        expect(helper.time_ago(now - 30.seconds)).to eq("about 30 seconds ago")
      end
    end

    context "when time difference is in minutes" do
      it "returns about a minute ago" do
        expect(helper.time_ago(now - 1.minute)).to eq("about a minute ago")
      end

      it "returns about x minutes ago" do
        expect(helper.time_ago(now - 20.minutes)).to eq("about 20 minutes ago")
      end
    end

    context "when time difference is in hours" do
      it "returns about an hour ago" do
        expect(helper.time_ago(now - 1.hour)).to eq("about an hour ago")
      end

      it "returns about x hours ago" do
        expect(helper.time_ago(now - 3.hours)).to eq("about 3 hours ago")
      end
    end

    context "when time difference is in days" do
      it "returns about a day ago" do
        expect(helper.time_ago(now - 1.day)).to eq("about a day ago")
      end

      it "returns about x days ago" do
        expect(helper.time_ago(now - 2.days)).to eq("about 2 days ago")
      end

      it "returns about x days ago" do
        expect(helper.time_ago(now - 5.days)).to eq("about 5 days ago")
      end
    end

    context "when time difference is in weeks" do
      it "returns about a week ago" do
        expect(helper.time_ago(now - 8.days)).to eq("about a week ago")
      end

      it "returns about x weeks ago" do
        expect(helper.time_ago(now - 3.weeks)).to eq("about 3 weeks ago")
      end
    end

    context "when time difference is in weeks and days" do
      it "returns about x weeks and a day ago" do
        expect(helper.time_ago(now - 29.days)).to eq("about 4 weeks and a day ago")
      end

      it "returns about x weeks and x days ago" do
        expect(helper.time_ago(now - 30.days)).to eq("about 4 weeks and 2 days ago")
      end
    end

    context "when time difference is in months" do
      it "returns about a month ago" do
        expect(helper.time_ago(now - 32.days)).to eq("about a month ago")
      end

      it "returns about x months ago" do
        expect(helper.time_ago(now - 75.days)).to eq("about 3 months ago")
      end
    end

    context "when time difference is in years" do
      it "returns about a year ago" do
        expect(helper.time_ago(now - 1.year)).to eq("about a year ago")
      end

      it "returns about x years ago" do
        expect(helper.time_ago(now - 2.years)).to eq("about 2 years ago")
      end

      it "returns over x years ago" do
        expect(helper.time_ago(now - 3.years)).to eq("over 3 years ago")
      end

      it "returns almost x years ago" do
        expect(helper.time_ago(now - 5.years)).to eq("almost 5 years ago")
      end
    end

    context "when providing a custom locale and scope" do
      it "uses the provided locale and scope" do
        custom_locale = :es
        custom_scope = "custom.datetime.time_ago"
        options = { locale: custom_locale, scope: custom_scope }

        expect(I18n).to receive(:with_options).with(locale: custom_locale, scope: custom_scope).and_call_original
        helper.time_ago(now - 1.hour, now, options)
      end
    end
  end

  describe "#time_ago_with_tooltip" do
    let(:time) { Time.zone.now - 5.minutes }

    it "returns a time tag with default attributes" do
      result = helper.time_ago_with_tooltip(time)
      expect(result).to include("class=\"js-timeago\"")
      expect(result).to include("title=\"#{time.to_fs(:long)}\"")
      expect(result).to include("datetime=\"#{time.utc.iso8601}\"")
      expect(result).to include("data-controller=\"tooltip\"")
      expect(result).to include("data-bs-placement=\"top\"")
    end

    it "includes js-short-timeago class when short_format is true" do
      result = helper.time_ago_with_tooltip(time, short_format: true)

      expect(result).to include("class=\"js-short-timeago\"")
    end

    it "appends custom HTML classes" do
      result = helper.time_ago_with_tooltip(time, html_class: "custom-class")

      expect(result).to include("class=\"js-timeago custom-class\"")
    end

    it "sets tooltip placement correctly" do
      result = helper.time_ago_with_tooltip(time, placement: "bottom")

      expect(result).to include("data-bs-placement=\"bottom\"")
    end
  end
end
