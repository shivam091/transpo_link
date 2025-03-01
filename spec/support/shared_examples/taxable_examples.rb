# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "tax type" do
  describe "enums" do
    it { is_expected.to define_enum_for(:tax_type).backed_by_column_of_type(:enum) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:INTERNATIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:REGIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:NATIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:COUNTRY_REQUIRING_TAX_TYPES) }
  end

  describe "validations" do
    describe "#tax_type" do
      it { is_expected.to validate_presence_of(:tax_type) }
      it { is_expected.to validate_inclusion_of(:tax_type).in_array(described_class.tax_types.values) }
    end

    describe "#country" do
      context "when #tax_type requires the country" do
        before { allow(subject).to receive(:requires_country?) { true } }

        it { is_expected.to validate_presence_of(:country) }
      end

      context "when #tax_type does not require the country" do
        before { allow(subject).to receive(:requires_country?) { false } }

        it { is_expected.not_to validate_presence_of(:country) }
      end
    end
  end
end
