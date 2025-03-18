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

    describe "cuit" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "cuit", country: "AR")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "20-12345678-9",
            "27-87654321-0",
            "23-12345678-9",
            "30-87654321-0"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "20-12345678-91",
            "27876543210",
            "23-1234568-1",
            "87654321"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "cuil" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "cuil", country: "AR")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "20-12345678-9",
            "27-87654321-0",
            "23-12345678-9",
            "30-87654321-0"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "20-12345678-91",
            "27876543210",
            "23-1234568-1",
            "87654321"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "ruc" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "ruc", country: country)
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier, :country) do
          "10-12345678-9" | "PE"
          "15-87654321-0" | "PE"
          "17-16273849-0" | "PE"
          "8-12345678"    | "PA"
          "8-87654321"    | "PA"
          "1101234567890" | "EC"
          "2791234567890" | "EC"
          "1-12345678"    | "PY"
          "2-12345678"    | "PY"
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier, :country) do
          "20-87654321-0" | "PE"
          "20123456780"   | "PE"
          "21123456780"   | "PE"
          "2-12345678"    | "PA"
          "3-87654321"    | "PA"
          "511234567890"  | "EC"
          "0791234567890" | "EC"
          "112345678"     | "PY"
          "2-123456789"   | "PY"
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "cnpj" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "cnpj", country: "BR")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "12.345.678/0001-95",
            "98.765.432/0001-12",
            "12.234.456/7890-12"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "12345678000195",
            "12.345.678/0001",
            "12.234.456/789-12"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "cpf" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "cpf", country: "BR")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "123.456.789-09",
            "987.654.321-00",
            "456.789.123-45"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "123.456.789",
            "12345678909",
            "abc.def.ghi-jk",
            "00000000000",
            "11111111111",
            "55555555555",
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "abn" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "abn", country: "AU")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "51 824 753 556",
            "83 914 571 673",
            "51824753556"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "100 123 456 789",
            "51 000 1000 000",
            "99 999 999 9991"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "qst" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "qst", country: "CA")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "QST1234567890TQ0001",
            "QST1234567890TQ0002",
            "QST9876543210TQ1234",
            "QST1122334455TQ9999"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "QST123456789TQ0001",
            "1234567890TQ0001",
            "QST1234567890TQ",
            "QSTABCDEFGHIJTQ0001",
            "QST1122334455TQ0000",
            "QST1234567890TQ10000"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "tfn" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "tfn", country: "AU")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "12345678",
            "123 456 78",
            "123456789",
            "123 456 789"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "00000000",
            "11111111",
            "55555555",
            "000000000",
            "111111111",
            "555555555",
            "ABC123456",
            "1234567890",
            "123 456 7890"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "ird" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "ird", country: "NZ")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "12345678",
            "12-345-678",
            "987654321",
            "987-654-321",
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "1234567",
            "1234ABCD",
            "9876543210",
            "987-654-3210",
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "trn" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "trn", country: "AE")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "100123456789012",
            "100987654321098"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "10012345678901",
            "1001234567890123",
            "200123456789012",
            "100ABCDEFGHJKLMN",
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "inn" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "inn", country: "RU")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "1234567890",
            "123456789012",
            "1234 56789 0",
            "1234 567890 12"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "1234 567890 1",
            "1234 56789 02",
            "0000000000",
            "000000000000",
            "2222222222",
            "222222222222",
            "ABC1234567",
            "1234567890123"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "nie" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "nie", country: "ES")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "X0123456A",
            "Y6543210Z"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "B0123456A",
            "A6543210Z"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "nif" do
      let(:legal_identifier) do
        TaxIdentifier.new(tax_identifier: tax_identifier, tax_identifier_type: "nif", country: "ES")
      end

      context "when tax identifier is valid for country" do
        where(:tax_identifier) do
          [
            "01234567A",
            "76543210Z"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when tax identifier is invalid for country" do
        where(:tax_identifier) do
          [
            "B01234567",
            "A76543210"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end
  end
end
