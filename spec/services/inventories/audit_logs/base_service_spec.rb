# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/audit_logs/base_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::AuditLogs::BaseService, type: :service do
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

  subject(:service_instance) { described_class.new(inventory, movement) }

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
