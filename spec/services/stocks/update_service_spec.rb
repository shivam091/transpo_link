# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/stocks/update_service_spec.rb

require "spec_helper"

RSpec.describe Stocks::UpdateService, type: :service do
  let!(:inventory) { create(:inventory) }

  let(:stock) { inventory.stock }

  describe ".call" do
    context "when incrementing stock quantities" do
      let(:updates) { {quantity_in_hand: 5, quantity_pending_to_buyer: 3} }

      subject(:service_response) { described_class.(inventory, updates, :increment) }

      it "increases quantity_in_hand and quantity_pending_to_buyer" do
        expect {
          service_response
        }.to change {
          stock.reload.quantity_in_hand
        }.from(0).to(5).and change {
          stock.reload.quantity_pending_to_buyer
        }.from(0).to(3)
      end
    end

    context "when decrementing stock quantities" do
      before { stock.update!(quantity_in_hand: 10, quantity_pending_to_buyer: 5) }

      let(:updates) { {quantity_in_hand: 2, quantity_pending_to_buyer: 1} }

      subject(:service_response) { described_class.(inventory, updates, :decrement) }

      it "decreases the stock quantities correctly" do
        expect {
          service_response
        }.to change {
          stock.reload.quantity_in_hand
        }.from(10).to(8).and change {
          stock.reload.quantity_pending_to_buyer
        }.from(5).to(4)
      end
    end

    context "with invalid attribute in updates" do
      let(:updates) { {invalid_attribute: 10} }

      subject(:service_response) { described_class.(inventory, updates, :increment) }

      it "raises ArgumentError" do
        expect { service_response }.to raise_error(ArgumentError, /Invalid attribute/)
      end

      it "does not change any stock attribute" do
        expect {
          begin
            service_response
          rescue ArgumentError
          end
        }.not_to change { stock.reload.attributes }
      end
    end

    context "with invalid action" do
      let(:updates) { {quantity_in_hand: 5} }

      subject(:service_response) { described_class.(inventory, updates, :multiply) }

      it "raises ArgumentError for invalid action" do
        expect { service_response }.to raise_error(ArgumentError, /Invalid action/)
      end
    end

    context "when inventory is nil" do
      let(:updates) { {quantity_in_hand: 5} }

      subject(:service_response) { described_class.(nil, updates, :increment) }

      it "raises NoMethodError" do
        expect { service_response }.to raise_error(NoMethodError)
      end
    end
  end
end
