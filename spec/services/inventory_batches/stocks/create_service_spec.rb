# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_batches/stocks/create_service_spec.rb

require "spec_helper"

RSpec.describe InventoryBatches::Stocks::CreateService, type: :service do
  subject(:service_response) { described_class.(inventory_batch) }

  before do
    allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
    allow_any_instance_of(InventoryBatch).to receive(:create_stock)
  end

  describe ".call" do
    context "with a valid inventory" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) { create(:inventory_batch, quantity: 10, source: purchase_order_item) }

      include_examples "creates a record", InventoryBatch::Stock
    end

    context "with an invalid inventory (nil)" do
      let(:inventory_batch) { nil }

      it "raises ActiveRecord::RecordInvalid" do
        expect { service_response }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
