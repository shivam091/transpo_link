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

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity_pending_from_supplier).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0)}
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:inventory_id).unique }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_replenishments_inventory_id_on_inventories).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_replenishments_quantity_pending_from_supplier_non_negativ).with_expression("quantity_pending_from_supplier >= 0.0") }
    it { is_expected.to have_check_constraint(:check_replenishments_quantity_pending_from_supplier_presence).with_expression("quantity_pending_from_supplier IS NOT NULL") }
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
