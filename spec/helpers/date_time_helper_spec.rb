# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/date_time_helper_spec.rb

require "spec_helper"

RSpec.describe DateTimeHelper, type: :helper do
  let(:user) do
    build_stubbed(:user,
      preferred_date_format: :long,
      preferred_time_format: :twelve_hours_short,
      preferred_datetime_format: :default_twelve_hours,
      preferred_time_zone: "Asia/Tokyo"
    )
  end

  before do
    allow_any_instance_of(Warden::Proxy).to receive(:authenticate!) { user }
    allow(helper).to receive(:current_user) { user }
  end

  let(:time) { Time.utc(2024, 1, 1, 10, 30, 0) } # 2024-01-01 10:30:00 UTC
  let(:date) { time.to_date }
  let(:datetime) { time.to_datetime }

  describe "#time_ago" do
    let!(:now) { Time.zone.now }

    before { allow(I18n).to receive(:t).and_call_original }

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
      let!(:custom_locale) { :es }
      let!(:custom_scope) { "custom.datetime.time_ago" }
      let!(:options) { {locale: custom_locale, scope: custom_scope} }

      it "uses the provided locale and scope" do
        expect(I18n).to receive(:with_options).with(locale: custom_locale, scope: custom_scope).and_call_original

        helper.time_ago(now - 1.hour, now, options)
      end
    end
  end

  describe "#time_ago_with_tooltip" do
    around do |example|
      Time.use_zone("UTC") { example.run }
    end

    def element(**arguments)
      @time = Time.zone.parse("2015-07-02 08:23")
      html = helper.time_ago_with_tooltip(@time, **arguments)

      Loofah.fragment(html).at("time")
    end

    it "returns a time element" do
      expect(element.name).to eq("time")
    end

    it "includes the time_ago display text" do
      expect(element.text).to eq(time_ago(@time))
    end

    it "has a datetime attribute" do
      expect(element["datetime"]).to eq("2015-07-02T08:23:00Z")
    end

    it "uses bs_title for tooltip content" do
      expect(element["data-bs-title"]).to eq(I18n.l(@time, format: :default_twelve_hours))
    end

    it "defaults to js-timeago class" do
      expect(element["class"]).to eq("js-timeago")
    end

    it "accepts a custom html_class" do
      expect(element(html_class: "custom").attr("class")).to eq("js-timeago custom")
    end

    it "uses default placement top" do
      expect(element["data-bs-placement"]).to eq("top")
    end

    it "accepts a custom tooltip placement" do
      expect(element(placement: "bottom")["data-bs-placement"]).to eq("bottom")
    end

    it "adds controller=tooltip for Stimulus" do
      expect(element["data-controller"]).to eq("tooltip")
    end

    it "adds short timeago class if short_format is true" do
      expect(element(short_format: true)["class"]).to eq("js-short-timeago")
    end

    it "returns nil if time is nil" do
      expect(helper.time_ago_with_tooltip(nil)).to be_nil
    end
  end

  describe "#prettify_date" do
    it "returns nil for blank values" do
      expect(helper.prettify_date(nil)).to be_nil
    end

    it "uses the user's preferred date format" do
      expect(helper.prettify_date(date)).to eq(I18n.l(date, format: :long))
    end

    it "uses the passed format if given" do
      expect(helper.prettify_date(date, format: :short)).to eq(I18n.l(date, format: :short))
    end

    it "converts timezone if asked (has no effect on Date)" do
      expect(helper.prettify_date(date, convert_timezone: true)).to eq(I18n.l(date, format: :long))
    end
  end

  describe "#prettify_time" do
    it "returns nil for blank values" do
      expect(helper.prettify_time(nil)).to be_nil
    end

    it "uses the user's preferred time format and converts zone" do
      expect(prettify_with_zone(:prettify_time, time)).to eq(
        I18n.l(time.in_time_zone(user.preferred_time_zone), format: :twelve_hours_short)
      )
    end

    it "uses the passed format if given" do
      expect(prettify_with_zone(:prettify_time, time, format: :twenty_four_hours_long)).to eq(
        I18n.l(time.in_time_zone(user.preferred_time_zone), format: :twenty_four_hours_long)
      )
    end

    it "does not convert time zone if not requested" do
      expect(helper.prettify_time(time, convert_timezone: false)).to eq(
        I18n.l(time, format: :twelve_hours_short)
      )
    end
  end

  describe "#prettify_datetime" do
    it "returns nil for blank values" do
      expect(helper.prettify_datetime(nil)).to be_nil
    end

    it "uses the user's preferred datetime format and converts zone" do
      expect(prettify_with_zone(:prettify_datetime, datetime)).to eq(
        I18n.l(datetime.in_time_zone(user.preferred_time_zone), format: :default_twelve_hours)
      )
    end

    it "uses the passed format if given" do
      expect(prettify_with_zone(:prettify_datetime, datetime, format: :long)).to eq(
        I18n.l(datetime.in_time_zone(user.preferred_time_zone), format: :long)
      )
    end

    it "does not convert timezone if not requested" do
      expect(helper.prettify_datetime(datetime, convert_timezone: false)).to eq(
        I18n.l(datetime, format: :default_twelve_hours)
      )
    end
  end
end
