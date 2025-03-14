# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/acts_as_money_spec.rb

require "spec_helper"

RSpec.describe ActsAsMoney do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :acts_as_money_models, force: true do |t|
        t.string :currency
        t.timestamps
      end
    end

    class ActsAsMoneyModel < ApplicationRecord
      include ActsAsMoney
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:acts_as_money_models, if_exists: true)
    Object.send(:remove_const, :ActsAsMoneyModel)
  end

  subject { ActsAsMoneyModel.new(currency: "USD") }

  describe "#currency" do
    it "returns a Money::Currency object" do
      expect(subject.currency).to be_a(Money::Currency)
    end

    it "returns the correct currency based on the stored value" do
      expect(subject.currency.iso_code).to eq("USD")
    end

    it "handles invalid currency codes gracefully" do
      subject.currency = "INVALID"

      expect { subject.currency }.to raise_error(Money::Currency::UnknownCurrency)
    end
  end
end
