# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/presenters/warehouse_presenter_spec.rb

RSpec.describe WarehousePresenter, type: :presenter do
  let(:warehouse) { instance_double("Warehouse", total_capacity: 1000, capacity_unit: "kg") }
  let(:view_context) { double("view_context") }
  let(:presenter) { described_class.new(warehouse, view_context) }

  describe "#capacity" do
    it "returns formatted capacity with unit" do
      expect(presenter.capacity).to eq("1000 kg")
    end

    it "returns blank if values are nil" do
      allow(warehouse).to receive(:total_capacity).and_return(nil)
      allow(warehouse).to receive(:capacity_unit).and_return(nil)

      expect(presenter.capacity).to eq("")
    end
  end

  describe "#warehouse" do
    it "returns the original warehouse object" do
      expect(presenter.warehouse).to eq(warehouse)
    end
  end
end
