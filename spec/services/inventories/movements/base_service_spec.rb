# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/movements/base_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::Movements::BaseService, type: :service do
  let(:inventory) { create(:inventory) }
  let(:source) { create(:purchase_order_item) }
  let(:movement_attributes) do
    {
      quantity: 2.0,
      unit_id: source.unit_id,
      unit_cost: 5.0,
      total_cost: 10.0,
      currency: "USD"
    }
  end

  subject(:service_instance) { described_class.new(inventory, source, movement_attributes) }

  describe "#type" do
    it "raises NotImplementedError" do
      expect { service_instance.send(:type) }.to raise_error(NotImplementedError, /Subclasses must implement `type`/)
    end
  end
end
