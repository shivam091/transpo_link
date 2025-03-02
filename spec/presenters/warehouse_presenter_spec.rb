# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/presenters/warehouse_presenter_spec.rb

RSpec.describe WarehousePresenter, type: :presenter do
  let(:warehouse) { instance_double("Warehouse", total_capacity: 1000, capacity_unit: "kg", latitude: 45.6789, longitude: -123.4567) }
  let(:view_context) { double("view_context") }
  let(:presenter) { described_class.new(warehouse, view_context) }

  describe "#capacity" do
    it "returns formatted capacity with unit" do
      expect(presenter.capacity).to eq("1,000 kg")
    end

    it "returns blank if values are nil" do
      allow(warehouse).to receive(:total_capacity){ nil }
      allow(warehouse).to receive(:capacity_unit){ nil }

      expect(presenter.capacity).to eq("")
    end
  end

  describe "#formatted_latitude" do
    it "returns formatted latitude with degree symbol" do
      expect(presenter.formatted_latitude).to eq("45.6789°")
    end

    it "returns nil if latitude is nil" do
      allow(warehouse).to receive(:latitude){ nil }

      expect(presenter.formatted_latitude).to be_nil
    end
  end

  describe "#formatted_longitude" do
    it "returns formatted longitude with degree symbol" do
      expect(presenter.formatted_longitude).to eq("-123.4567°")
    end

    it "returns nil if longitude is nil" do
      allow(warehouse).to receive(:longitude){ nil }

      expect(presenter.formatted_longitude).to be_nil
    end
  end

  describe "#warehouse" do
    it "returns the original warehouse object" do
      expect(presenter.warehouse).to eq(warehouse)
    end
  end
end
