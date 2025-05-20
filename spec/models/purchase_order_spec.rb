# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder, type: :model do
  subject(:purchase_order) { build(:purchase_order) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(AASM) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Navigable) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum) }
  end

  describe "default values" do
    let(:purchase_order) { described_class.new }

    it "should set draft as default value for #status" do
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
    let!(:purchase_order) { create(:purchase_order) }

    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:submitted).on_event(:submit) }
    it { is_expected.to transition_from(:submitted).to(:approved).on_event(:approve) }
    it { is_expected.to transition_from(:submitted).to(:rejected).on_event(:reject) }
    it { is_expected.to transition_from(:draft).to(:cancelled).on_event(:cancel) }
    it { is_expected.to transition_from(:submitted).to(:cancelled).on_event(:cancel) }
    it { is_expected.to transition_from(:on_hold).to(:cancelled).on_event(:cancel) }
    it { is_expected.to transition_from(:submitted).to(:on_hold).on_event(:hold) }
    it { is_expected.to transition_from(:approved).to(:shipped).on_event(:ship) }
    it { is_expected.to transition_from(:approved).to(:on_hold).on_event(:hold) }
    it { is_expected.to transition_from(:on_hold).to(:approved).on_event(:resume) }
    it { is_expected.to transition_from(:approved).to(:partially_delivered).on_event(:partially_deliver) }
    it { is_expected.to transition_from(:approved).to(:fully_delivered).on_event(:fully_deliver) }
    it { is_expected.to transition_from(:partially_delivered).to(:fully_delivered).on_event(:fully_deliver) }
    it { is_expected.to transition_from(:fully_delivered).to(:closed).on_event(:close) }
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
      let(:warehouse) { build_stubbed(:warehouse) }
      let(:manager) { build_stubbed(:manager) }
      let(:supplier) { build_stubbed(:supplier) }

      it { is_expected.to validate_presence_of(:status) }

      it "allows valid status values" do
        described_class.statuses.keys.each do |status|
          expect(build(:purchase_order, status:, warehouse:, manager:, supplier:)).to be_valid
        end
      end

      it "raises error on invalid status value" do
        expect {
          build(:purchase_order, status: "invalid_status")
        }.to raise_error(ArgumentError, /is not a valid status/)
      end
    end

    describe "#notes" do
      it { is_expected.to validate_length_of(:notes).is_at_most(1000).allow_blank }
    end
  end

  include_examples "apply default scope on created_at:desc"

  describe "instance methods" do
    let!(:purchase_order) { create(:purchase_order) }

    describe "#key_associations" do
      it "returns array of key associations" do
        expect(purchase_order.key_associations).to eq(
          [
            purchase_order.warehouse,
            purchase_order.manager,
            purchase_order.supplier
          ]
        )
      end
    end

    describe "#reject_purchase_order_item?" do
      let!(:purchase_order_item) { create(:purchase_order_item, purchase_order:) }

      context "when creating purchase order items" do
        context "when valid attributes are provided" do
          let!(:another_product) { create(:product) }

          it "creates a purchase order item" do
            expect {
                purchase_order.update(purchase_order_items_attributes: {
                  0 => {
                    product_id: another_product.id,
                    quantity: 92,
                    unit_id: another_product.unit.id,
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
                  quantity: 0.0,
                  unit_id: "",
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
              quantity: 20
            })
          }.to not_change(PurchaseOrderItem, :count)

          expect(purchase_order_item.reload.quantity).to eq(20)
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

    describe "#all_items_delivered?" do
      let(:purchase_order) { create(:purchase_order, :with_po_items) }

      context "when all items are delivered" do
        before { purchase_order.purchase_order_items.each(&:deliver!) }

        it "returns true" do
          expect(purchase_order.send(:all_items_delivered?)).to be_truthy
        end
      end

      context "when some items are not delivered" do
        before { purchase_order.purchase_order_items.first.cancel! }

        it "returns false" do
          expect(purchase_order.send(:all_items_delivered?)).to be_falsy
        end
      end

      context "when no items are delivered" do
        before { purchase_order.purchase_order_items.each(&:cancel!) }

        it "returns false" do
          expect(purchase_order.send(:all_items_delivered?)).to be_falsy
        end
      end
    end

    describe "#some_items_delivered_or_partially_delivered?" do
      let(:purchase_order) { create(:purchase_order, :with_po_items) }

      context "when some items are delivered" do
        before { purchase_order.purchase_order_items.first.deliver! }

        it "returns true" do
          expect(purchase_order.send(:some_items_delivered_or_partially_delivered?)).to be_truthy
        end
      end

      context "when some items are partially delivered" do
        before { purchase_order.purchase_order_items.first.partially_deliver! }

        it "returns true" do
          expect(purchase_order.send(:some_items_delivered_or_partially_delivered?)).to be_truthy
        end
      end

      context "when no items are delivered or partially delivered" do
        before { purchase_order.purchase_order_items.each(&:cancel!) }

        it "returns false" do
          expect(purchase_order.send(:some_items_delivered_or_partially_delivered?)).to be_falsy
        end
      end
    end

    describe "#synchronize_delivery_status!" do
      let(:purchase_order) { create(:purchase_order, :with_po_items) }

      context "when all items are delivered" do
        before do
          purchase_order.purchase_order_items.each(&:deliver!)

          allow(purchase_order).to receive(:may_fully_deliver?) { true }
          allow(purchase_order).to receive(:fully_deliver!).and_call_original
          allow(purchase_order).to receive(:partially_deliver!)

          purchase_order.synchronize_delivery_status!
        end

        it "sets the status to fully_delivered" do
          expect(purchase_order).to have_received(:fully_deliver!).once
        end

        it "does not change status if fully_deliver cannot transition" do
          allow(purchase_order).to receive(:may_fully_deliver?) { false }

          expect { purchase_order.synchronize_delivery_status! }.not_to change { purchase_order.status }
        end
      end

      context "when some items are delivered or partially delivered" do
        before do
          purchase_order.purchase_order_items.first.deliver!  # Deliver the first item

          allow(purchase_order).to receive(:may_partially_deliver?) { true }
          allow(purchase_order).to receive(:fully_deliver!)
          allow(purchase_order).to receive(:partially_deliver!).and_call_original

          purchase_order.synchronize_delivery_status!
        end

        it "sets the status to partially_delivered" do
          expect(purchase_order).to have_received(:partially_deliver!).once
        end

        it "does not change status if partially_deliver cannot transition" do
          allow(purchase_order).to receive(:may_partially_deliver?) { false }

          expect { purchase_order.synchronize_delivery_status! }.not_to change { purchase_order.status }
        end
      end

      context "when no items are delivered or partially delivered" do
        before do
          purchase_order.purchase_order_items.each(&:cancel!)  # Ensure all items are cancelled

          allow(purchase_order).to receive(:fully_deliver!)  # Spy on fully_deliver! method
          allow(purchase_order).to receive(:partially_deliver!)  # Spy on partially_deliver! method

          purchase_order.synchronize_delivery_status!  # Explicitly call the method
        end

        it "does not change the status" do
          # Ensure no method is called since the status shouldn't change
          expect(purchase_order).not_to have_received(:fully_deliver!)
          expect(purchase_order).not_to have_received(:partially_deliver!)
        end
      end

      context "when an invalid transition occurs" do
        before do
          purchase_order.purchase_order_items.each(&:deliver!)  # Deliver items to make the transition possible

          # Simulate invalid transition by allowing a failed transition
          allow(purchase_order).to receive(:may_fully_deliver?).and_raise(AASM::InvalidTransition.new(purchase_order, :draft, :default))
        end

        it "logs the error for invalid transition" do
          expect(Rails.logger).to receive(:error).with("Failed to synchronize PO delivery status: Event 'draft' cannot transition from 'draft'.")

          purchase_order.synchronize_delivery_status!
        end
      end
    end

    describe "#update_delivered_at" do
      let(:purchase_order) { create(:purchase_order, :approved, delivered_at: nil) }

      it "sets delivered_at to current time on delivery" do
        freeze_time do
          expect {
            purchase_order.fully_deliver!
          }.to change {
            purchase_order.reload.delivered_at
          }.from(nil).to(Date.current)
        end
      end
    end
  end

  describe "class methods and scopes" do
    describe ".accessible" do
      let!(:purchase_order) { create(:purchase_order) }

      it "returns list of accessible purchase orders" do
        expect(described_class.accessible(purchase_order.manager)).to include(purchase_order)
      end
    end
  end
end
