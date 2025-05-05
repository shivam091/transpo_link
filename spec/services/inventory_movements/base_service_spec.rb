# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_movements/base_service_spec.rb

require "spec_helper"

RSpec.describe InventoryMovements::BaseService, type: :service do
  let(:inventory) { create(:inventory) }
  let(:source) { create(:purchase_order_item) }
  let(:inventory_movement_attributes) do
    {
      quantity: 2.0,
      unit_id: source.unit_id,
      unit_cost: 5.0,
      total_cost: 10.0,
      currency: "USD"
    }
  end

  subject(:service_instance) { described_class.new(inventory, source, inventory_movement_attributes) }

  describe "#type" do
    it "raises NotImplementedError" do
      expect { service_instance.send(:type) }.to raise_error(NotImplementedError, /Subclasses must implement `type`/)
    end
  end
end
