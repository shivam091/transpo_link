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
            "12-2324252"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_valid }
        end
      end

      context "when business identifier is invalid for country" do
        where(:business_identifier) do
          [
            "123456789",
            "123-456789"
          ]
        end

        with_them do
          it { expect(legal_identifier).to be_invalid }
        end
      end
    end
  end
end
