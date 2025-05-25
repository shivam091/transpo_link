# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/rejection/create_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Rejection::CreateService, type: :service do
  let!(:purchase_order) { create(:purchase_order) }

  subject(:service_response) { described_class.(purchase_order, rejection_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:user) { create(:supplier) }
      let(:rejection_attributes) { attributes_for(:purchase_order_rejection, user_id: user.id) }

      include_examples "creates a record", PurchaseOrder::Rejection
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:rejection_attributes) { attributes_for(:purchase_order_rejection, reason: "") }

      include_examples "does not change record count", PurchaseOrder::Rejection
      include_examples "returns an error response"
    end
  end
end
