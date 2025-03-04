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

  subject { TaxableModel.new(tax_type: "gstin", country: "IN") }

  describe "enums" do
    it { is_expected.to define_enum_for(:tax_type).backed_by_column_of_type(:enum) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:EU_COUNTRIES_ISO2) }
    it { is_expected.to have_constant(:VALID_TAX_TYPE_COUNTRY_COMBINATIONS) }
  end

  describe "validations" do
    describe "#tax_type" do
      it { is_expected.to validate_presence_of(:tax_type) }
      # it { is_expected.to validate_inclusion_of(:tax_type).in_array(TaxableModel.tax_types.values) }
    end

    describe "#country" do
      it { is_expected.to validate_presence_of(:country) }
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
  end
end
