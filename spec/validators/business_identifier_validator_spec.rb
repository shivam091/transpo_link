# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/business_identifier_validator_spec.rb

require "spec_helper"

RSpec.describe BusinessIdentifierValidator do
  using RSpec::Parameterized::TableSyntax

  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :business_identifiers, force: true do |t|
        t.string :business_identifier_type
        t.string :business_identifier
        t.string :country
        t.timestamps
      end
    end

    class BusinessIdentifier < ApplicationRecord
      validates :business_identifier, business_identifier: true
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:business_identifiers, if_exists: true)
    Object.send(:remove_const, :BusinessIdentifier)
  end

  describe "#validate_each" do
    describe "ein" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "ein", country: "US")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
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

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
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

    describe "llpin" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "llpin", country: "IN")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "A123456",
            "B987654",
            "Z000001",
            "M765432",
            "K543210"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "1234567",
            "AB12345",
            "A12B456",
            "a123456",
            "A1234567",
            "X1234"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "abn" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "abn", country: "AU")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
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

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
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

    describe "acn" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "acn", country: "AU")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "123 456 789",
            "987654321",
            "851 753 462"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "012 345 6789",
            "999 9999 999",
            "1111 222 333"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "siren" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "siren", country: "FR")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "732 829 320",
            "552100554",
            "349567598"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "732 829 3201",
            "123 456 7890"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "siret" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "siret", country: "FR")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "732 829 320 00074",
            "73282932000074",
            "41298331200018"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "732 829 3201",
            "123 456 7890"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "bn" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "bn", country: "CA")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
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

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
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
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "uen", country: "SG")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
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

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
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
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "cuit", country: "AR")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
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

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
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
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "ruc", country: country)
      end

      context "when business identifier is valid for country" do
        where(:business_identifier, :country) do
          "10-12345678-9" | "PE"
          "20-12345678-0" | "PE"
          "21-12345678-0" | "PE"
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

      context "when business identifier is invalid for country" do
        where(:business_identifier, :country) do
          "10123456789"   | "PE"
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

    describe "hrb" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "hrb", country: "DE")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "HRB 123456",
            "HRB 98765432",
            "HRB1234567"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "HRB 12345",
            "HRB 123456789"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end

    describe "cnpj" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "cnpj", country: "BR")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
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

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
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

    describe "vkn" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "vkn", country: "TR")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "1234567890",
            "9876543210",
            "2345678901"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "12345",
            "0000000000",
            "2222222222",
            "12345ABCDE"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end
    describe "cif" do
      let(:legal_identifier) do
        BusinessIdentifier.new(business_identifier: business_identifier, business_identifier_type: "cif", country: "ES")
      end

      context "when business identifier is valid for country" do
        where(:business_identifier) do
          [
            "A12345678",
            "B12345678"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "1234567B",
            "A1234567B"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end
  end
end
