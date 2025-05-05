# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/audit_logs/create_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::AuditLogs::CreateService, type: :service do
  let(:source_unit) { create(:dozen_unit) }
  let(:target_unit) { create(:item_unit) }
  let!(:unit_conversion) { create(:dozen_item_conversion, source_unit:, target_unit:) }

  let!(:inventory) { create(:inventory, unit: target_unit) }
  let!(:movement) { create(:inventory_movement, :purchase, inventory:, unit: target_unit) }

  subject(:service_response) { described_class.(inventory, movement) }

  describe ".call" do
    context "when type is purchase" do
      before { allow(movement).to receive(:type) { :purchase } }

      it "calls the PurchaseService" do
        expect(Inventories::AuditLogs::PurchaseService).to receive(:call).with(inventory, movement)

        service_response
      end
    end

    context "when type is restock" do
      before { allow(movement).to receive(:type) { :restock } }

      it "calls the RestockService" do
        expect(Inventories::AuditLogs::RestockService).to receive(:call).with(inventory, movement)

        service_response
      end
    end

    context "when type is unsupported" do
      before { allow(movement).to receive(:type) { :unknown_type } }

      it "raises a NotImplementedError" do
        expect { service_response }.to raise_error(NotImplementedError, "Audit log service not implemented for unknown_type")
      end
    end
  end
end
