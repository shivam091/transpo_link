# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/tax_identifier_validator_spec.rb

require "spec_helper"

RSpec.describe TaxIdentifierValidator do
  using RSpec::Parameterized::TableSyntax

  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :tax_identifiers, force: true do |t|
        t.string :tax_identifier_type
        t.string :tax_identifier
        t.string :country
        t.timestamps
      end
    end

    class TaxIdentifier < ApplicationRecord
      validates :tax_identifier, tax_identifier: true
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:tax_identifiers, if_exists: true)
    Object.send(:remove_const, :TaxIdentifier)
  end

  describe "#validate_each" do
    describe "vat" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "vat", country: country)
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier, :country) do
          "ATU12345678"   | "AT"
          "U12345678"     | "AT"
          "BE0123456789"  | "BE"
          "0123456789"    | "BE"
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier, :country) do
          "AT123456789"   | "AT"
          "BVU12345678"   | "AT"
          "BE1123456789"  | "BE"
          "1123456789"    | "BE"
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end
  end
end
