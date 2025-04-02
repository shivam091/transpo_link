# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder, type: :model do
  subject { create(:purchase_order) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:manager_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:supplier_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_document).of_type(:string) }
    it { is_expected.to have_db_column(:order_date).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:expected_delivery_date).of_type(:date) }
    it { is_expected.to have_db_column(:actual_delivery_date).of_type(:date) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:notes).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:manager_id) }
    it { is_expected.to have_db_index(:order_date) }
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:supplier_id) }
    it { is_expected.to have_db_index(:warehouse_id) }

    it { is_expected.to have_foreign_key(:manager_id).with_name(:fk_purchase_orders_manager_id_on_users).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:supplier_id).with_name(:fk_purchase_orders_supplier_id_on_users).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_purchase_orders_warehouse_id_on_warehouses).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_purchase_orders_notes_length).with_expression("char_length(notes) <= 1000") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_reference_document_length).with_expression("char_length(reference_document::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_expected_delivery_after_order).with_expression("expected_delivery_date >= order_date") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_status_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_purchase_orders_status_presence).with_expression("status IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(AASM) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum) }
  end

  describe "default values" do
    let(:purchase_order) { described_class.new }

    it "should set 'draft' as default value for #status" do
      expect(purchase_order.status).to eq("draft")
    end
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:reference_document) }
    it { is_expected.to nullify_if_blank(:notes) }
    it { is_expected.to nullify_if_blank(:expected_delivery_date) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:reference_document) }
    it { is_expected.to sanitize_attribute(:notes) }
  end

  describe "state machines" do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:pending).on_event(:pending) }
    it { is_expected.to transition_from(:pending).to(:approved).on_event(:approve) }
    it { is_expected.to transition_from(:pending).to(:cancelled).on_event(:cancel) }
    it { is_expected.to transition_from(:pending).to(:rejected).on_event(:reject) }
    it { is_expected.to transition_from(:approved).to(:partially_delivered).on_event(:partially_deliver) }
    it { is_expected.to transition_from(:approved).to(:fully_delivered).on_event(:fully_deliver) }
    it { is_expected.to transition_from(:partially_delivered).to(:fully_delivered).on_event(:fully_deliver) }
  end

  describe "associations" do
    it { is_expected.to have_many(:purchase_order_items).inverse_of(:purchase_order).dependent(:destroy) }

    it { is_expected.to belong_to(:warehouse).inverse_of(:purchase_orders) }
    it { is_expected.to belong_to(:manager).inverse_of(:purchase_orders) }
    it { is_expected.to belong_to(:supplier).inverse_of(:supplied_purchase_orders) }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:purchase_order_items).allow_destroy(true) }
  end

  describe "validations" do
    describe "#warehouse_id" do
      it { is_expected.to validate_presence_of(:warehouse_id) }
    end

    describe "#manager_id" do
      it { is_expected.to validate_presence_of(:manager_id) }
    end

    describe "#supplier_id" do
      it { is_expected.to validate_presence_of(:supplier_id) }
    end

    describe "#reference_document" do
      it { is_expected.to validate_length_of(:reference_document).is_at_most(55).allow_blank }
    end

    describe "#expected_delivery_date" do
      it { is_expected.to validate_comparison_of(:expected_delivery_date).is_greater_than_or_equal_to(:order_date).allow_nil }
    end

    describe "#status" do
      it { is_expected.to validate_presence_of(:status) }
      # it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }
    end

    describe "#notes" do
      it { is_expected.to validate_length_of(:notes).is_at_most(1000).allow_blank }
    end
  end

  describe "instance methods" do
    let!(:purchase_order) { create(:purchase_order) }

    describe "#reject_purchase_order_item?" do
      let!(:purchase_order_item) { create(:purchase_order_item, purchase_order: purchase_order) }

      context "when creating purchase order items" do
        context "when valid attributes are provided" do
          let!(:product) { create(:product) }

          it "creates a purchase order item" do
            expect {
                purchase_order.update(purchase_order_items_attributes: {
                  0 => {
                    product_id: product.id,
                    ordered_quantity: 92,
                    uom: "mg",
                    unit_cost: 100,
                    currency: "INR"
                  }
                })
            }.to change(PurchaseOrderItem, :count).by(1)
          end
        end

        context "when invalid attributes are provided" do
          it "does not create a purchase order item if required attributes are blank" do
            expect {
              purchase_order.update(purchase_order_items_attributes: {
                0 => {
                  ordered_quantity: 0.0,
                  uom: "",
                  unit_cost: "",
                  currency: ""
                }
              })
            }.to not_change(PurchaseOrderItem, :count)
          end
        end
      end

      context "when updating purchase order items" do
        it "updates the existing purchase order item without changing the count" do
          expect {
            purchase_order.update(purchase_order_items_attributes: {
              id: purchase_order_item.id,
              ordered_quantity: 20
            })
          }.to not_change(PurchaseOrderItem, :count)

          expect(purchase_order_item.reload.ordered_quantity).to eq(20)
        end
      end

      context "when destroying purchase order items" do
        it "removes the purchase order item when _destroy is set to true" do
          expect {
            purchase_order.update(purchase_order_items_attributes: {id: purchase_order_item.id, _destroy: true})
          }.to change(PurchaseOrderItem, :count).by(-1)
        end
      end
    end
  end
end
