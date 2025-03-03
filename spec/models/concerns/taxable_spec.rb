# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/taxable_spec.rb

require "spec_helper"

RSpec.describe Taxable do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :taxable_models, force: true do |t|
        t.enum :tax_type, enum_type: :tax_types
        t.string :country
        t.timestamps
      end
    end

    class TaxableModel < ApplicationRecord
      include Taxable
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:taxable_models, if_exists: true)
    Object.send(:remove_const, :TaxableModel)
  end

  subject { TaxableModel.new(tax_type: "vat", country: "IN") }

  describe "enums" do
    it { is_expected.to define_enum_for(:tax_type).backed_by_column_of_type(:enum) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:INTERNATIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:REGIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:NATIONAL_TAX_TYPES) }
    it { is_expected.to have_constant(:COUNTRY_REQUIRING_TAX_TYPES) }
    it { is_expected.to have_constant(:EU_COUNTRIES_ISO2) }
    it { is_expected.to have_constant(:VALID_TAX_TYPE_COUNTRY_COMBINATIONS) }
  end

  describe "validations" do
    describe "#tax_type" do
      it { is_expected.to validate_presence_of(:tax_type) }
      # it { is_expected.to validate_inclusion_of(:tax_type).in_array(TaxableModel.tax_types.values) }
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

  describe "#tax_type_country_combination" do
    let(:taxable_model) { TaxableModel.new(tax_type: tax_type, country: country) }

    context "when tax_type and country are a valid combination" do
      let(:tax_type) { "vat" }
      let(:country) { "DE" }

      it "does not add errors" do
        taxable_model.valid?

        expect(taxable_model.errors[:tax_type]).to be_empty
      end
    end

    context "when tax_type and country are an invalid combination" do
      let(:tax_type) { "gstin" }
      let(:country) { "US" }

      it "adds an error to tax_type" do
        taxable_model.valid?

        expect(taxable_model.errors[:tax_type]).to be_present
      end
    end

    context "when tax_type is present but country is missing" do
      let(:tax_type) { "ein" }
      let(:country) { nil }

      it "does not validate tax_type-country combination" do
        taxable_model.valid?

        expect(taxable_model.errors[:tax_type]).to be_empty
      end
    end
  end

  describe "#set_country" do
    let(:taxable_model) { TaxableModel.new(tax_type: tax_type, country: country) }

    context "when country is present" do
      let(:tax_type) { "ein" }
      let(:country) { "US" }

      it "does not change the country" do
        taxable_model.valid?
        expect(taxable_model.country).to eq("US")
      end
    end

    context "when country is blank and tax_type requires a country" do
      let(:tax_type) { "vat" }
      let(:country) { nil }

      it "does not set a country" do
        taxable_model.valid?
        expect(taxable_model.country).to be_nil
      end
    end

    context "when tax_type is not recognized" do
      let(:taxable_model) { TaxableModel.new(tax_type: "vat", country: nil) }

      before do
        allow(taxable_model).to receive(:tax_type).and_return("unknown_tax_type")
      end

      it "does not set a country" do
        taxable_model.valid?
        expect(taxable_model.country).to be_nil
      end
    end

    context "when country is blank and tax_type has a default country" do
      where(:tax_type, :expected_country) do
        [
          ["ein", "US"],
          ["ssn", "US"],
          ["itin", "US"],
          ["pan", "IN"],
          ["tan", "IN"],
          ["gstin", "IN"],
          ["nif", "ES"],
          ["cif", "ES"],
          ["siret", "FR"],
          ["siren", "FR"],
          ["utr", "GB"],
          ["bn", "CA"],
          ["qst", "CA"],
          ["abn", "AU"],
          ["acn", "AU"],
          ["tfn", "AU"],
          ["ird", "NZ"],
          ["rfc", "MX"],
          ["cuit", "AR"],
          ["cuil", "AR"],
          ["cnpj", "BR"],
          ["cpf", "BR"],
          ["npwp", "ID"],
          ["trn", "AE"],
          ["kra_pin", "KE"],
          ["corporate_number", "JP"],
          ["my_number", "JP"],
          ["inn", "RU"],
          ["kpp", "RU"],
          ["ogrn", "RU"],
          ["ogrnip", "RU"],
          ["brn_kr", "KR"],
          ["uscc", "CN"],
          ["mst", "VN"],
          ["tin_ph", "PH"],
          ["tin_th", "TH"],
          ["uen", "SG"]
        ]
      end

      with_them do
        let(:country) { nil }

        it "sets the correct country" do
          taxable_model.valid?
          expect(taxable_model.country).to eq(expected_country)
        end
      end
    end
  end
end
