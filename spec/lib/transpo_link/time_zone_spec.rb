# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/time_zone_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::TimeZone do
  describe ".formatted_time_zone" do
    it "returns formatted time zone string" do
      expect(described_class.formatted_time_zone("Asia/Kolkata")).to eq("(GMT +05:30) Asia/Kolkata")
    end

    it "returns the nil if the time zone is invalid" do
      expect(described_class.formatted_time_zone("Invalid/Zone")).to be_nil
    end
  end

  describe ".formatted_offset" do
    it "returns formatted formatted offset" do
      expect(described_class.formatted_offset(19800)).to eq("+05:30")
    end
  end

  describe ".options_for_time_zones" do
    it "returns a collection of formatted time zones" do
      expect(described_class.options_for_time_zones).to include(["(GMT +05:30) Mumbai", "Asia/Kolkata"])
    end
  end

  describe ".with_user_time_zone" do
    let(:user) { double("User", preferred_time_zone: "Asia/Kolkata") }

    it "executes the block within the user's preferred time zone" do
      described_class.with_user_time_zone(user) do
        expect(Time.zone.name).to eq("Asia/Kolkata")
      end
    end

    it "defaults to nil if user is nil" do
      described_class.with_user_time_zone(nil) do
        expect(Time.zone.name).to eq(Time.zone_default.name)
      end
    end
  end

  describe ".with_default_time_zone" do
    it "executes the block within the default time zone" do
      described_class.with_default_time_zone do
        expect(Time.zone.name).to eq(Time.zone_default.name)
      end
    end
  end
end
