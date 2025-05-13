# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/replenishment_spec.rb

require "spec_helper"

RSpec.describe Replenishment, type: :model do
  subject(:replenishment) { build(:replenishment) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:replenishment) }
  end

  describe "default values" do
    let(:replenishment) { described_class.new }

    it "should set 0.0 as default value for #quantity_pending_from_supplier" do
      expect(replenishment.quantity_pending_from_supplier).to eq(0.0)
    end
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity_pending_from_supplier) }
  end

  describe "validations" do
    describe "#quantity_pending_from_supplier" do
      it { is_expected.to validate_presence_of(:quantity_pending_from_supplier) }

      context "when quantity_pending_from_supplier < 0.0" do
        it "is invalid" do
          replenishment.quantity_pending_from_supplier = -1.0
          replenishment.validate

          expect(replenishment.errors[:quantity_pending_from_supplier]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when quantity_pending_from_supplier >= 0.0" do
        it "is valid" do
          replenishment.quantity_pending_from_supplier = 0.0
          replenishment.validate

          expect(replenishment.errors[:quantity_pending_from_supplier]).to be_empty
        end
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory).inverse_of(:replenishment).touch }
  end
end
