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
    context "when merge succeeds after unit conversion" do
      let(:inventory_batch_attributes) do
        {
          quantity: 2,
          unit_id: inventory_batch.unit_id
        }
      end

      it "updates the batch quantity by adding the given amount" do
        expect {
          service_response
        }.to change { inventory_batch.reload.quantity }.by(2)
      end

      include_examples "returns a success response"
    end

    context "when unit conversion raises an error" do
      let(:source_unit) { build_stubbed(:dozen_unit) }
      let(:target_unit) { build_stubbed(:item_unit) }

      let(:inventory_batch_attributes) do
        {
          quantity: 2,
          unit_id: source_unit.id
        }
      end

      before do
        allow(inventory_batch).to receive(:unit) { target_unit }
        allow(UnitConversion).to receive(:convert).and_raise(UnitConversionError.new(source_unit, target_unit))
      end

      it "raises a UnitConversionError and does not update the quantity" do
        expect {
          service_response
        }.to raise_error(UnitConversionError, /Please ensure a valid unit conversion exists./i)
      end
    end

    context "when merge fails after successful conversion" do
      let(:inventory_batch_attributes) do
        {
          quantity: 2,
          unit_id: inventory_batch.unit_id
        }
      end

      before do
        allow(UnitConversion).to receive(:convert) { 2 }
        allow(inventory_batch).to receive(:merge_with!) { false }
      end

      it "does not change the batch quantity" do
        expect {
          service_response
        }.to not_change { inventory_batch.reload.quantity }
      end

      include_examples "returns an error response"
    end
  end
end
