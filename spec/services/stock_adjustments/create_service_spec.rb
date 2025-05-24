# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/stock_adjustments/create_service_spec.rb

require "spec_helper"

RSpec.describe StockAdjustments::CreateService, type: :service do
  let(:user) { create(:admin) }

  let(:inventory_batch) { create(:inventory_batch) }

  before do
    allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
    allow_any_instance_of(InventoryBatch).to receive(:validate_quantity_does_not_exceed_item_received_quantity)
  end

  subject(:service_response) { described_class.(inventory_batch, stock_adjustment_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:stock_adjustment_attributes) { attributes_for(:stock_adjustment, unit_id: inventory_batch.unit_id, user_id: user.id) }

      include_examples "creates a record", StockAdjustment
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:stock_adjustment_attributes) { attributes_for(:stock_adjustment) }

      include_examples "does not change record count", StockAdjustment
      include_examples "returns an error response"
    end
  end
end
