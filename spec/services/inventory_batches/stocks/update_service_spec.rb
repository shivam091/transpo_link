# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_batches/stocks/update_service_spec.rb

require "spec_helper"

RSpec.describe InventoryBatches::Stocks::UpdateService, type: :service do
  let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
  let(:inventory_batch) { create(:inventory_batch, source: purchase_order_item) }

  subject(:service_response) { described_class.(inventory_batch, stock_attributes) }

  before { allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:stock_attributes) { {restocked_quantity: 5} }

      it "updates the stock" do
        expect { service_response }.to change { inventory_batch.stock.restocked_quantity }.by(5)
      end
    end

    context "when provided attributes are invalid" do
      let(:stock_attributes) { {restocked_quantity: nil} }

      it "does not update the stock and raises error" do
        expect { service_response }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
