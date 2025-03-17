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
          "ATU10223006"       | "AT"
          "ATU98765432"       | "AT"
          "ATU66655408"       | "AT"
          "U12345678"         | "AT"
          "BE0123456789"      | "BE"
          "BE0467891234"      | "BE"
          "BE0765432101"      | "BE"
          "0123456789"        | "BE"
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier, :country) do
          "ATX12345678"       | "AT"
          "BVU12345678"       | "AT"
          "ATU00000000"       | "AT"
          "ATU9999999"        | "AT"
          "ATX12345678"       | "AT"
          "BE1234567890"      | "BE"
          "BE1234.567.890"    | "BE"
          "BE9876543210"      | "BE"
          "BE0000000000"      | "BE"
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "ein" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "ein", country: "US")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "12-3456789",
            "50-1234567",
            "83-9876543",
            "01-2345678"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "90-1234567",
            "00-1234567",
            "9X-XXXXXXX"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "ssn" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "ssn", country: "US")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "001-01-0001",
            "665-99-9999",
            "667-01-0001",
            "899-99-9999",
            "750-01-0001",
            "763-99-9999",
            "764-01-0001",
            "899-99-9999",
            "555-50-1234",
            "489-36-8350",
            "514-14-8905",
            "690-05-5315",
            "421-37-1396"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "555501234",
            "1234567890",
            "666-99-9999",
            "000-99-9999",
            "999-99-0000",
            "999-99-9999"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "itin" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "itin", country: "US")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "900-50-0000",
            "900-59-0000",
            "900-60-0000",
            "900-65-0000",
            "900-70-0000",
            "900-79-0000",
            "999-88-9999",
            "912-90-0000",
            "999-92-9999",
            "900-94-0000",
            "999-99-9999"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "800-50-0000",
            "900-66-0000",
            "999-83-1234",
            "999-89-9999",
            "999-93-9999",
            "999-01-9999",
            "999-12-3456"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "pan" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "pan", country: "IN")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "AAAPA1234A",
            "AAAFI1234A",
            "AACCB1234A",
            "AAHHS1234A",
            "AATTA1234A",
            "AABCA1234A"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "AEU454455Z",
            "1234567890",
            "1234P5455A",
            "AA1AX1234A",
            "AAAPA12345"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "gstin" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "gstin", country: "IN")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "07AAAPA1234A1Z3",
            "27AAAFI1234A1Z7",
            "29AACCB3455A1Z9",
            "32AAHHS1234A2Z4",
            "21AATTA1234A3Z4"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "07abcZ1234F1Z5",
            "07ABCDE1234F1Z",
            "07ABCDE1234F12Z",
            "07ABCDE1234F1Z0",
            "40AACCB1234A1Z9",
            "98AACCB1234A1Z9"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "tan" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "tan", country: "IN")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "PDES03028F",
            "ABCX12345A",
            "RAJA99999B"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "12345A1234",
            "ABCDE12345",
            "XYZA11111C4"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "bn" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "bn", country: "CA")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "123456789",
            "987654321 RT0001",
            "123456789 RC0002",
            "567890123 RP9999",
            "162738490 RM9876"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "012345678",
            "12345678",
            "123456789 R0001",
            "123456789 RT000",
            "567890123 AB9999"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "uen" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "uen", country: "SG")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "S12345678A",
            "T98765432Z",
            "201234567K",
            "T08GA1234A",
            "F21LL1234B",
            "S21LL1234B",
            "G21LL1234B"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "X1234567A",
            "T1234567890A",
            "12345678",
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end
  end
end
