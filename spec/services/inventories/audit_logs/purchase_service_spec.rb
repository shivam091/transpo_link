# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/audit_logs/purchase_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::AuditLogs::PurchaseService, type: :service do
  let(:source_unit) { create(:dozen_unit) }
  let(:target_unit) { create(:item_unit) }
  let(:unit_conversion) { create(:dozen_item_conversion, source_unit:, target_unit:) }

  let!(:inventory) { create(:inventory, unit: target_unit) }

  let!(:movement) do
    create(:inventory_movement,
      :purchase,
      quantity: 2.0,
      source: inventory,
      unit: target_unit,
      inventory:
    )
  end

  subject(:service_response) { described_class.(inventory, movement) }

  include_context "with current user"

  describe ".call" do
    before { allow_any_instance_of(Inventory::Movement).to receive(:create_audit_log) }

    context "when type is purchase" do
      let!(:prior_purchases) do
        create_list(:inventory_movement, 2, :purchase, quantity: 5.0, inventory:, unit: target_unit)
      end

      include_examples "creates a record", Inventory::AuditLog

      it "sets correct audit log attributes for purchase" do
        audit_log = service_response.payload[:audit_log]

        expected_previous_quantity = prior_purchases.sum(&:quantity) # 10.0
        expected_new_quantity = expected_previous_quantity + movement.quantity # 12.0

        expect(audit_log.type).to eq("purchase")
        expect(audit_log.previous_quantity).to eq(expected_previous_quantity)
        expect(audit_log.new_quantity).to eq(expected_new_quantity)
      end

      include_examples "returns a success response"
    end

    context "when audit log creation fails due to validation error" do
      before { allow_any_instance_of(Inventory::AuditLog).to receive(:save) { false } }

      include_examples "does not change record count", Inventory::AuditLog
      include_examples "returns an error response"
    end
  end
end
