# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/tax_rate_spec.rb

require "spec_helper"

RSpec.describe TaxRate, type: :model do
  subject(:tax_rate) { build(:tax_rate) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:tax_rate) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:business_category).with_values({b2b: "b2b", b2c: "b2c"}).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:tax_type).with_values({exclusive: "exclusive", inclusive: "inclusive"}).backed_by_column_of_type(:enum) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "default values" do
    let(:tax_rate) { described_class.new }

    it "should set b2b as default value for #business_category" do
      expect(tax_rate.business_category).to eq("b2b")
    end

    it "should set exclusive as default value for #tax_type" do
      expect(tax_rate.tax_type).to eq("exclusive")
    end
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Taxable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:rate) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:valid_to) }
  end

  describe "validations" do
    describe "#tax_identifier_type" do
      # it do
      #   is_expected.to validate_uniqueness_of(:tax_identifier_type)
      #     .scoped_to([:country, :business_category, :tax_type, :valid_from])
      #     .with_message("already exist for this country, tax type, and business category for selected date")
      #     .case_insensitive
      # end
    end

    describe "#business_category" do
      it { is_expected.to validate_presence_of(:business_category) }
      # it { is_expected.to validate_inclusion_of(:business_category).in_array(described_class.business_categories.values) }
    end

    describe "#tax_type" do
      it { is_expected.to validate_presence_of(:tax_type) }
      # it { is_expected.to validate_inclusion_of(:tax_type).in_array(described_class.tax_types.values) }
    end

    describe "#rate" do
      it { is_expected.to validate_presence_of(:rate) }

      context "when rate < 0.0" do
        it "is invalid" do
          tax_rate.rate = -1.0
          tax_rate.validate

          expect(tax_rate.errors[:rate]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when rate > 100.0" do
        it "is invalid" do
          tax_rate.rate = 101.0
          tax_rate.validate

          expect(tax_rate.errors[:rate]).to include("must be less than or equal to 100.0")
        end
      end

      context "when rate <= 100.0 and rate >= 0.0" do
        it "is valid" do
          tax_rate.rate = 16.0
          tax_rate.validate

          expect(tax_rate.errors[:rate]).to be_empty
        end
      end
    end

    describe "#valid_from" do
      it { is_expected.to validate_presence_of(:valid_from) }
      it { is_expected.to validate_comparison_of(:valid_from).is_greater_than_or_equal_to(Date.current).with_message("must be today or a future date").on(:create) }
    end

    describe "#valid_to" do
      it { is_expected.to validate_comparison_of(:valid_to).is_greater_than(:valid_from).allow_nil }
    end
  end

  describe "class methods and scopes" do
    let!(:active_tax_rate) { create(:tax_rate, :gstin) }
    let!(:future_tax_rate) { create(:tax_rate, :inclusive, :b2c, country: "IN", valid_from: Date.current + 1.year, valid_to: Date.current + 5.years) }

    describe ".active" do
      it "returns only active tax rates" do
        expect(described_class.active).to include(active_tax_rate)
        expect(described_class.active).to exclude(future_tax_rate)
      end
    end

    describe ".future" do
      it "returns only future tax rates" do
        expect(described_class.future).to include(future_tax_rate)
        expect(described_class.future).to exclude(active_tax_rate)
      end
    end

    describe ".expired" do
      it "returns only expired tax rates" do
        travel_to(10.year.from_now) do
          expect(described_class.expired).to include(active_tax_rate)
          expect(described_class.expired).to include(future_tax_rate)
        end
      end
    end

    describe ".active_rate" do
      it "returns the tax rate for a current date" do
        expect(described_class.active_rate("IN", "gstin")).to eq(active_tax_rate)
        expect(described_class.active_rate("IN", "gstin")).to_not eq(future_tax_rate)
      end
    end

    describe ".future_rate" do
      it "returns the tax rate for a future date" do
        expect(described_class.future_rate("IN", "gstin", Date.current + 1.year)).to eq(future_tax_rate)
        expect(described_class.future_rate("IN", "gstin", Date.current + 1.year)).to_not eq(active_tax_rate)
      end
    end

    describe ".for_country" do
      it "returns tax rates for the given country" do
        expect(described_class.for_country("IN")).to include(future_tax_rate)
        expect(described_class.for_country("DE")).to exclude(future_tax_rate)
      end
    end

    describe ".for_tax_identifier_type" do
      it "returns tax rates for the given tax identifier type" do
        expect(described_class.for_tax_identifier_type("gstin")).to include(active_tax_rate)
        expect(described_class.for_tax_identifier_type("pan")).to_not include(active_tax_rate)
      end
    end

    describe ".for_tax_type" do
      it "returns tax rates for the given tax type" do
        expect(described_class.for_tax_type("exclusive")).to include(active_tax_rate)
        expect(described_class.for_tax_type("inclusive")).not_to include(active_tax_rate)
      end
    end

    describe ".for_business_category" do
      it "returns tax rates for the given business category" do
        expect(described_class.for_business_category("b2c")).to include(future_tax_rate)
        expect(described_class.for_business_category("b2b")).to exclude(future_tax_rate)
      end
    end

    describe ".applicable_rates" do
      it "returns applicable tax rates matching tax identifier type, country, and category" do
        expect(described_class.applicable_rates("gstin", "IN", "b2b")).to include(active_tax_rate)
        expect(described_class.applicable_rates("pan", "IN", "b2c")).to_not include(active_tax_rate)
      end
    end

    describe ".valid_on" do
      it "returns tax rates valid on given date" do
        expect(described_class.valid_on(Date.current + 1.year)).to exclude(active_tax_rate)
        expect(described_class.valid_on(Date.current + 1.year)).to include(future_tax_rate)
      end
    end

    include_examples "apply default scope on created_at:desc"
  end

  describe "instance methods" do
    describe "#no_overlapping_tax_rates" do
      let!(:existing_tax_rate) { create(:tax_rate) }

      context "when creating a tax rate with overlapping valid dates" do
        let(:new_tax_rate) { build(:tax_rate, valid_from: Date.current + 1.day, valid_to: Date.current + 2.years) }

        it "is not valid" do
          expect(new_tax_rate).to_not be_valid
          expect(new_tax_rate.errors[:base]).to include("There is already an active tax rate for this country, tax identifier type, tax type, and business category in the selected date range")
        end
      end

      context "when creating a tax rate with overlapping valid dates but with other business category" do
        let(:new_tax_rate) { build(:tax_rate, business_category: "b2c") }

        it { expect(new_tax_rate).to be_valid }
      end

      context "when creating a tax rate with non-overlapping valid dates" do
        let(:new_tax_rate) { build(:tax_rate, valid_from: Date.current + 2.years, valid_to: Date.current + 3.years) }

        it { expect(new_tax_rate).to be_valid }
      end
    end

    describe "#cannot_change_rate_for_active_tax_rate" do
      context "when updating the rate of an active tax rate" do
        let(:active_tax_rate) { create(:tax_rate) }

        it "is not valid" do
          active_tax_rate.rate = 10.0

          expect(active_tax_rate).to_not be_valid
          expect(active_tax_rate.errors[:rate]).to include("cannot be changed for an active tax rate")
        end
      end

      context "when updating the rate before the tax rate becomes active" do
        let(:future_tax_rate) { create(:tax_rate, valid_from: Date.current + 1.month, valid_to: Date.current + 2.year) }

        it "is valid" do
          future_tax_rate.rate = 10.0

          expect(future_tax_rate).to be_valid
        end
      end
    end
  end
end
