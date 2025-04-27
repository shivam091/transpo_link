# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/scale_enforcer_spec.rb

require "spec_helper"

RSpec.describe ScaleEnforcer do
  before(:all) do
    connection.create_table :scale_enforced_models, force: true do |t|
      t.decimal :price, precision: 10, scale: 2
      t.decimal :discount, precision: 5, scale: 1
      t.timestamps
    end

    class ScaleEnforcedModel < ApplicationRecord
      include ScaleEnforcer

      scale_attributes :price, :discount
    end
  end

  after(:all) do
    connection.drop_table :scale_enforced_models, if_exists: true
    Object.send(:remove_const, :ScaleEnforcedModel)
  end

  subject { ScaleEnforcedModel.new }

  it { expect(ScaleEnforcedModel).to respond_to(:scale_attributes) }

  describe "callbacks" do
    it { expect(ScaleEnforcedModel).to have_callback(:before, :validation, :apply_scale) }
  end

  describe "custom matchers" do
    it { is_expected.to apply_scale_to(:price) }
    it { is_expected.to apply_scale_to(:discount) }
  end

  describe "#scale_attributes" do
    it "stores the correct scale for each attribute" do
      column = ScaleEnforcedModel.columns_hash["price"]
      expect(column.scale).to eq(2)

      column = ScaleEnforcedModel.columns_hash["discount"]
      expect(column.scale).to eq(1)
    end
  end

  describe "#apply_scale" do
    it "does not alter the attribute if it is nil" do
      subject.price = nil
      subject.discount = nil

      subject.valid?

      expect(subject.price).to be_nil
      expect(subject.discount).to be_nil
    end

    it "does not alter the attribute if the value is blank" do
      subject.price = ""
      subject.discount = ""

      subject.valid?

      expect(subject.price).to be_nil
      expect(subject.discount).to be_nil
    end

    it "does not alter the attribute if it is already rounded" do
      subject.price = 19.99
      subject.discount = 12.3

      subject.valid?

      # Compare BigDecimal values as strings
      expect(subject.price).to eq(BigDecimal("19.99"))
      expect(subject.discount).to eq(BigDecimal("12.3"))
    end

    it "rounds the price attribute to 2 decimal places" do
      subject.price = 19.995

      subject.valid?

      # Compare BigDecimal values as strings
      expect(subject.price).to eq(BigDecimal("20.0"))
    end

    it "rounds the discount attribute to 1 decimal place" do
      subject.discount = 12.345

      subject.valid?

      # Compare BigDecimal values as strings
      expect(subject.discount).to eq(BigDecimal("12.3"))
    end
  end
end
