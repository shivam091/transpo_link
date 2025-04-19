# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/time_zone_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::TimeZone do
  describe ".formatted_time_zone" do
    it "returns formatted time zone string" do
      expect(described_class.formatted_time_zone("Mumbai")).to eq("(GMT +05:30) Mumbai")
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

  describe ".select_options" do
    it "returns a collection of formatted time zones" do
      expect(described_class.select_options).to include(["(GMT +05:30) Mumbai", "Mumbai"])
    end
  end

  describe ".with_user_time_zone" do
    let(:user) { double("User", preferred_time_zone: "Mumbai") }

    it "executes the block within the user's preferred time zone" do
      described_class.with_user_time_zone(user) do
        expect(Time.zone.name).to eq("Mumbai")
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
