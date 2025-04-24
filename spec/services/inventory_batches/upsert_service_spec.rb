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
    context "when no batch exists" do
      let(:inventory_batch_attributes) do
        {
          batch_number: "B001",
          expiration_date: 1.year.from_now,
          unit: purchase_order_item.unit,
          quantity: purchase_order_item.quantity,
          cost_price: purchase_order_item.unit_cost
        }
      end

      include_examples "creates a record", InventoryBatch
      include_examples "returns a success response"
    end

    context "when batch already exists" do
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
          unit: existing_batch.unit,
          quantity: existing_batch.quantity,
          cost_price: existing_batch.cost_price
        }
      end

      it "merges the batch quantity" do
        expect { service_response }.to change { existing_batch.reload.quantity }.by(3)
      end

      include_examples "returns a success response"
    end
  end
end
