# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_batches/merge_service_spec.rb

require "spec_helper"

RSpec.describe InventoryBatches::MergeService, type: :service do
  let!(:unit) do
    create(:dozen_unit).tap do |dozen_unit|
      create(:dozen_item_conversion, source_unit: dozen_unit)
    end
  end
  let!(:inventory_batch) { create(:inventory_batch, quantity: 5, unit:) }

  subject(:service_response) { described_class.(inventory_batch, inventory_batch_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:inventory_batch_attributes) do
        {
          quantity: 2,
          unit: inventory_batch.unit
        }
      end

      it "increments the batch quantity" do
        expect { service_response }.to change { inventory_batch.reload.quantity }.by(2)
      end

      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:inventory_batch_attributes) { {quantity: 2, unit: nil} }

      before do
        allow(UnitConversion).to receive(:convert) { nil }
        allow(inventory_batch).to receive(:increment!) { false }
      end

      it "does not increment the batch quantity" do
        expect { service_response }.to not_change { inventory_batch.reload.quantity }
      end

      include_examples "returns an error response"
    end
  end
end
