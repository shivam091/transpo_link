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

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:movement_type).of_type(:enum) }
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

    it { is_expected.to have_db_index([:inventory_id, :source_id, :source_type, :movement_type]) }
    it { is_expected.to have_db_index(:inventory_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:metadata) }
    it { is_expected.to have_db_index([:source_type, :source_id]) }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_inventory_movements_inventory_id_on_inventories).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventory_movements_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_inventory_movements_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_movement_type_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_inventory_movements_movement_type_presence).with_expression("movement_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_quantity_nonzero).with_expression("quantity <> 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_total_cost_gteq_unit_cost).with_expression("total_cost >= unit_cost") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_total_cost_presence).with_expression("total_cost IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_unit_cost_positive).with_expression("unit_cost > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_unit_cost_presence).with_expression("unit_cost IS NOT NULL") }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:movement_type).backed_by_column_of_type(:enum) }
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

  describe "validations" do
    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }
      it { is_expected.to validate_numericality_of(:quantity).is_other_than(0.0) }
    end

    describe "#unit_cost" do
      it { is_expected.to validate_presence_of(:unit_cost) }
      it { is_expected.to validate_numericality_of(:unit_cost).is_greater_than(0.0) }
    end

    describe "#total_cost" do
      it { is_expected.to validate_presence_of(:total_cost) }
      it { is_expected.to validate_numericality_of(:total_cost).is_greater_than_or_equal_to(:unit_cost) }
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
  end
end
