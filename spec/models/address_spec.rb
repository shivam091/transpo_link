# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/address_spec.rb

require "spec_helper"

RSpec.describe Address, type: :model do
  let(:attributes) do
    {
      address1: "Halvorson Rapids",
      address2: "Suite 380",
      city: "Port Ophelia",
      state: "KS",
      country: "US",
      postal_code: "79131"
    }
  end

  subject(:address) { build(:address, **attributes) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:address) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:address2) }
    it { is_expected.to nullify_if_blank(:state) }
    it { is_expected.to nullify_if_blank(:postal_code) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:address1) }
    it { is_expected.to sanitize_attribute(:address2) }
    it { is_expected.to sanitize_attribute(:city) }
    it { is_expected.to sanitize_attribute(:postal_code) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:addressable).touch }
  end

  describe "validations" do
    describe "#address1" do
      it { is_expected.to validate_presence_of(:address1) }
      it { is_expected.to validate_length_of(:address1).is_at_most(100) }
    end

    describe "#address2" do
      it { is_expected.to validate_length_of(:address2).is_at_most(100).allow_blank }
    end

    describe "#postal_code" do
      it { is_expected.to validate_length_of(:postal_code).is_at_most(20).allow_blank }
    end

    describe "#country" do
      it { is_expected.to validate_presence_of(:country) }
    end
  end

  describe "instance methods" do
    describe "#state_name" do
      it "returns name of the state" do
        expect(address.state_name).to eq("Kansas")
      end
    end

    describe "#country_name" do
      it "returns name of the country" do
        expect(address.country_name).to eq("United States")
      end
    end

    describe "#humanize" do
      it "returns humanized address" do
        expect(address.humanize).to eq("Halvorson Rapids, Suite 380, Port Ophelia, Kansas, United States, 79131")
      end
    end
  end
end
