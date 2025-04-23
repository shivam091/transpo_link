# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/replenishments/update_service_spec.rb

require "spec_helper"

RSpec.describe Replenishments::UpdateService, type: :service do
  let!(:inventory) { create(:inventory) }

  let(:replenishment) { inventory.replenishment }

  describe ".call" do
    context "when incrementing quantity_pending_from_supplier" do
      subject(:service_response) { described_class.(inventory, 5, :increment) }

      it "increases quantity_pending_from_supplier" do
        expect {
          service_response
        }.to change {
          replenishment.reload.quantity_pending_from_supplier
        }.from(0).to(5)
      end
    end

    context "when decrementing quantity_pending_from_supplier" do
      before { replenishment.update!(quantity_pending_from_supplier: 20) }

      subject(:service_response) { described_class.(inventory, 5, :decrement) }

      it "decreases quantity_pending_from_supplier" do
        expect {
          service_response
        }.to change {
          replenishment.reload.quantity_pending_from_supplier
        }.from(20).to(15)
      end
    end

    context "when given an invalid action" do
      subject(:service_response) { described_class.(inventory, 5, :invalid_action) }

      it "raises ArgumentError" do
        expect { service_response }.to raise_error(ArgumentError, /Invalid action/)
      end

      it "does not change the quantity" do
        expect {
          begin
            service_response
          rescue ArgumentError
          end
        }.not_to change {
          replenishment.reload.quantity_pending_from_supplier
        }
      end
    end

    context "when inventory is nil" do
      subject(:service_response) { described_class.(nil, 5, :increment) }

      it "raises NoMethodError" do
        expect { service_response }.to raise_error(NoMethodError)
      end
    end
  end
end
