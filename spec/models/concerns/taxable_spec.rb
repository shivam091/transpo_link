# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/taxable_spec.rb

require "spec_helper"

RSpec.describe Taxable do
  before(:all) do
    connection.create_table :taxable_models, force: true do |t|
      t.string :tax_identifier_type
      t.string :country
      t.timestamps
    end

    class TaxableModel < ApplicationRecord
      include Taxable
    end
  end

  after(:all) do
    connection.drop_table :taxable_models, if_exists: true
    Object.send(:remove_const, :TaxableModel)
  end

  subject { TaxableModel.new(tax_identifier_type: "gstin", country: "IN") }

  describe "enums" do
    it { is_expected.to define_enum_for(:tax_identifier_type).backed_by_column_of_type(:string) }
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:tax_identifier).from("  ABCDE1234a  ").to("ABCDE1234A") }
  end

  describe "constants" do
    it { is_expected.to have_constant(:EU_COUNTRIES) }
    it { is_expected.to have_constant(:TAX_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS) }
  end

  describe "validations" do
    describe "#tax_identifier_type" do
      it { is_expected.to validate_presence_of(:tax_identifier_type) }
      # it { is_expected.to validate_inclusion_of(:tax_identifier_type).in_array(TaxableModel.tax_identifier_types.values) }
    end

    describe "#country" do
      it { is_expected.to validate_presence_of(:country) }
    end
  end

  describe "#tax_identifier_type_country_combination" do
    let(:taxable_model) { TaxableModel.new(tax_identifier_type: tax_identifier_type, country: country) }

    before { taxable_model.valid? }

    context "when tax identifier type and country combination is valid" do
      where(:tax_identifier_type, :country) do
        Taxable::TAX_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS.flat_map do |type, countries|
          countries.map { |country| [type.to_s, country] }
        end
      end

      with_them do
        it "allows #{params[:tax_identifier_type]} for #{params[:country]}" do
          expect(taxable_model.errors[:tax_identifier_type]).to be_empty
        end
      end
    end

    context "when tax identifier type and country combination is invalid" do
      where(:tax_identifier_type, :country) do
        [
          [:ssn, "CA"],  # SSN is not valid for CA
          [:nif, "GB"],  # NIF is not valid for GB
          [:pan, "US"],  # CIN is not valid for US
          [:cuit, "PE"], # RFC is not valid for PE
          [:ruc, "IN"],  # RUC is not valid for IN
          [:qst, "BR"],  # QST is not valid for BR
          [:uen, "FR"],  # NIT is not valid for FR
        ]
      end

      with_them do
        it "does not allow #{params[:tax_identifier_type]} for #{params[:country]}" do
          expect(taxable_model.errors[:tax_identifier_type]).to be_present
        end
      end
    end
  end
end
