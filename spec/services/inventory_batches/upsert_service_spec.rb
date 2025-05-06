# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_batches/upsert_service_spec.rb

require "spec_helper"

RSpec.describe InventoryBatches::UpsertService, type: :service do
  let!(:inventory) { create(:inventory) }

  let(:purchase_order_item) { create(:purchase_order_item, quantity: 3) }

  subject(:service_response) { described_class.(inventory, inventory_batch_attributes) }

  describe ".call" do
    context "when batch_number and expiration_date are provided" do
      context "when the matching batch does not exist" do
        let(:inventory_batch_attributes) do
          {
            batch_number: "B001",
            expiration_date: 1.year.from_now,
            unit_id: purchase_order_item.unit_id,
            quantity: 3,
            cost_price: purchase_order_item.unit_cost
          }
        end

        it "calls InventoryBatches::CreateService" do
          expect(InventoryBatches::CreateService)
            .to receive(:call)
            .with(inventory, inventory_batch_attributes)
            .and_call_original

          service_response
        end

        include_examples "creates a record", InventoryBatch
        include_examples "returns a success response"
      end

      context "when a matching batch already exists" do
        let!(:existing_batch) do
          create(:inventory_batch,
            inventory:,
            batch_number: "B001",
            expiration_date: 1.year.from_now,
            unit: purchase_order_item.unit,
            quantity: purchase_order_item.quantity,
            cost_price: purchase_order_item.unit_cost
          )
        end

        let(:inventory_batch_attributes) do
          {
            batch_number: existing_batch.batch_number,
            expiration_date: existing_batch.expiration_date,
            unit_id: existing_batch.unit_id,
            quantity: existing_batch.quantity,
            cost_price: existing_batch.cost_price
          }
        end

        it "calls InventoryBatches::MergeService" do
          expect(InventoryBatches::MergeService)
            .to receive(:call)
            .with(existing_batch, inventory_batch_attributes)
            .and_call_original

          service_response
        end

        it "merges quantity into the existing batch" do
          expect { service_response }.to change { existing_batch.reload.quantity }.by(3)
        end

        include_examples "returns a success response"
      end
    end

    context "when expiration date is not provided" do
      context "when the matching batch does not exist" do
        let(:inventory_batch_attributes) do
          {
            batch_number: "B002",
            expiration_date: nil,
            unit_id: purchase_order_item.unit_id,
            quantity: 3,
            cost_price: purchase_order_item.unit_cost
          }
        end

        it "calls InventoryBatches::CreateService" do
          expect(InventoryBatches::CreateService)
            .to receive(:call)
            .with(inventory, inventory_batch_attributes)
            .and_call_original

          service_response
        end

        include_examples "creates a record", InventoryBatch
        include_examples "returns a success response"
      end

      context "when matching batch exists" do
        let!(:existing_batch) do
          create(:inventory_batch,
            inventory:,
            batch_number: "B002",
            expiration_date: nil,
            unit: purchase_order_item.unit,
            quantity: 5,
            cost_price: purchase_order_item.unit_cost
          )
        end

        let(:inventory_batch_attributes) do
          {
            batch_number: existing_batch.batch_number,
            expiration_date: existing_batch.expiration_date,
            unit_id: existing_batch.unit_id,
            quantity: existing_batch.quantity,
            cost_price: existing_batch.cost_price
          }
        end

        it "calls InventoryBatches::MergeService" do
          expect(InventoryBatches::MergeService)
            .to receive(:call)
            .with(existing_batch, inventory_batch_attributes)
            .and_call_original

          service_response
        end

        it "merges quantity into the existing batch" do
          expect { service_response }.to change { existing_batch.reload.quantity }.by(5)
        end

        include_examples "returns a success response"
      end
    end
  end
end
