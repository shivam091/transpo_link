# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory/movement_spec.rb

require "spec_helper"

RSpec.describe Inventory::Movement, type: :model do
  subject(:inventory_movement) { build(:inventory_movement) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_movement) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:type).of_type(:enum) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:unit_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:total_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:movement_date).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:source_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:source_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:metadata).of_type(:jsonb).with_options(default: "{}") }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index([:inventory_id, :source_id, :source_type, :type]) }
    it { is_expected.to have_db_index(:inventory_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:metadata) }
    it { is_expected.to have_db_index([:source_type, :source_id]) }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_inventory_movements_inventory_id_on_inventories).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventory_movements_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_inventory_movements_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_type_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_inventory_movements_type_presence).with_expression("type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_quantity_nonzero).with_expression("quantity <> 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_total_cost_gteq_unit_cost).with_expression("total_cost >= unit_cost") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_total_cost_presence).with_expression("total_cost IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_unit_cost_positive).with_expression("unit_cost > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_unit_cost_presence).with_expression("unit_cost IS NOT NULL") }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:type).backed_by_column_of_type(:enum) }
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
    it { is_expected.to have_many(:audit_logs).class_name("Inventory::AuditLog").inverse_of(:movement).dependent(:destroy) }

    it { is_expected.to belong_to(:inventory).inverse_of(:movements) }
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

    describe "#type" do
      it { is_expected.to validate_presence_of(:type) }

      it "allows valid type values" do
        described_class.types.keys.each do |valid_type|
          expect(build(:inventory_movement, type: valid_type)).to be_valid
        end
      end

      it "raises error on invalid type value" do
        expect {
          build(:inventory_movement, type: "invalid_type")
        }.to raise_error(ArgumentError, /is not a valid type/)
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
        expect(InventoryAuditLogs::CreateService).to receive(:call).with(instance_of(Inventory), an_instance_of(Inventory::Movement))

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
