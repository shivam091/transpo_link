# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_movement_spec.rb

require "spec_helper"

RSpec.describe InventoryMovement, type: :model do
  subject(:inventory_movement) { build(:inventory_movement) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_movement) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:movement_type).backed_by_column_of_type(:enum) }
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
    it { is_expected.to include_module(Sortable) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity) }
    it { is_expected.to apply_scale_to(:unit_cost) }
    it { is_expected.to apply_scale_to(:total_cost) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventory_audit_logs).inverse_of(:inventory_movement).dependent(:destroy) }

    it { is_expected.to belong_to(:inventory).inverse_of(:inventory_movements) }
    it { is_expected.to belong_to(:source).optional }
    it { is_expected.to belong_to(:unit).inverse_of(:inventory_movements) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :save, :set_default_attributes) }
    it { is_expected.to have_callback(:after, :create, :create_inventory_audit_log) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      context "when quantity is invalid" do
        it "is invalid" do
          inventory_movement.quantity = "abcd"
          inventory_movement.validate

          expect(inventory_movement.errors[:quantity]).to include("must be other than 0.0")
        end
      end

      context "when quantity <= 0.0" do
        it "is invalid" do
          inventory_movement.quantity = 0.0
          inventory_movement.validate

          expect(inventory_movement.errors[:quantity]).to include("must be other than 0.0")
        end
      end

      context "when quantity > 0.0" do
        it "is valid" do
          inventory_movement.quantity = 1.0
          inventory_movement.validate

          expect(inventory_movement.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#unit_cost" do
      it { is_expected.to validate_presence_of(:unit_cost) }

      context "when unit_cost is invalid" do
        it "is invalid" do
          inventory_movement.unit_cost = "abcd"
          inventory_movement.validate

          expect(inventory_movement.errors[:unit_cost]).to include("must be greater than 0.0")
        end
      end

      context "when unit_cost <= 0.0" do
        it "is invalid" do
          inventory_movement.unit_cost = 0.0
          inventory_movement.validate

          expect(inventory_movement.errors[:unit_cost]).to include("must be greater than 0.0")
        end
      end

      context "when unit_cost > 0.0" do
        it "is valid" do
          inventory_movement.unit_cost = 1.0
          inventory_movement.validate

          expect(inventory_movement.errors[:unit_cost]).to be_empty
        end
      end
    end

    describe "#total_cost" do
      it { is_expected.to validate_presence_of(:total_cost) }

      context "when total_cost < unit_cost" do
        it "is invalid" do
          inventory_movement.unit_cost = 10.0
          inventory_movement.total_cost = 5.0
          inventory_movement.validate

          expect(inventory_movement.errors[:total_cost]).to include("must be greater than or equal to 10.0")
        end
      end

      context "when total_cost >= unit_cost" do
        it "is valid" do
          inventory_movement.unit_cost = 10.0
          inventory_movement.total_cost = 12.0
          inventory_movement.validate

          expect(inventory_movement.errors[:total_cost]).to be_empty
        end
      end
    end

    describe "#movement_type" do
      it { is_expected.to validate_presence_of(:movement_type) }

      it "allows valid movement_type values" do
        described_class.movement_types.keys.each do |valid_type|
          expect(build(:inventory_movement, movement_type: valid_type)).to be_valid
        end
      end

      it "raises error on invalid movement_type value" do
        expect {
          build(:inventory_movement, movement_type: "invalid_type")
        }.to raise_error(ArgumentError, /is not a valid movement_type/)
      end
    end
  end

  describe "instance methods" do
    describe "#set_default_attributes" do
      let(:inventory) { create(:inventory) }
      let(:inventory_movement) do
        build(:inventory_movement, inventory:, unit: inventory.unit, source: inventory)
      end

      it "sets the movement_date and metadata before saving" do
        freeze_time do
          inventory_movement.save!

          expect(inventory_movement.movement_date).to eq(Time.current.utc)
          expect(inventory_movement.metadata).to eq({ "action" => "restock" })
        end
      end
    end

    describe "#create_inventory_audit_log" do
      let(:inventory) { create(:inventory) }

      it "calls InventoryAuditLogs::CreateService after creation" do
        expect(InventoryAuditLogs::CreateService).to receive(:call).with(instance_of(Inventory), an_instance_of(InventoryMovement))

        create(:inventory_movement, inventory:, unit: inventory.unit)
      end
    end

    describe "#convert_to_inventory_unit" do
      let!(:source_unit) { create(:dozen_unit) }
      let!(:target_unit) { create(:item_unit) }

      let(:inventory) { create(:inventory, unit: target_unit) }
      let(:purchase_order_item) { create(:purchase_order_item, unit: target_unit) }

      context "when source and target units are the same" do
        let(:inventory_movement) { build(:inventory_movement, source: purchase_order_item, unit: target_unit, quantity: 10, inventory:) }

        it "does not change quantity or unit" do
          expect(UnitConversion).not_to receive(:convert)

          inventory_movement.save!

          expect(inventory_movement.quantity).to eq(10)
          expect(inventory_movement.unit).to eq(target_unit)
        end
      end

      context "when source and target units are different and conversion succeeds" do
        let(:inventory_movement) { build(:inventory_movement, source: purchase_order_item, unit: source_unit, quantity: 5, inventory:) }

        it "converts the quantity and sets unit to target unit" do
          allow(UnitConversion).to receive(:convert).with(source_unit, target_unit, 5) { 60 }

          inventory_movement.save!

          expect(inventory_movement.quantity).to eq(60)
          expect(inventory_movement.unit).to eq(target_unit)
        end
      end
    end
  end
end
