# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_audit_logs/base_service_spec.rb

require "spec_helper"

RSpec.describe InventoryAuditLogs::BaseService, type: :service do
  let(:unit) { create(:item_unit) }

  let!(:inventory) { create(:inventory, unit:) }
  let!(:inventory_movement) { create(:inventory_movement, :purchase, unit:, inventory:) }

  subject(:service_instance) { described_class.new(inventory, inventory_movement) }

  describe "#previous_quantity" do
    it "raises NotImplementedError" do
      expect { service_instance.send(:previous_quantity) }.to raise_error(NotImplementedError, /Subclasses must implement `previous_quantity`/)
    end
  end

  describe "#new_quantity" do
    it "raises NotImplementedError" do
      expect { service_instance.send(:new_quantity) }.to raise_error(NotImplementedError, /Subclasses must implement `new_quantity`/)
    end
  end
end
