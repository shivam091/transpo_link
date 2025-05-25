# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/approval/create_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::Approval::CreateService, type: :service do
  let!(:purchase_order) { create(:purchase_order) }

  subject(:service_response) { described_class.(purchase_order, approval_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:user) { create(:supplier) }
      let(:approval_attributes) { attributes_for(:purchase_order_approval, user_id: user.id) }

      include_examples "creates a record", PurchaseOrder::Approval
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:approval_attributes) { attributes_for(:purchase_order_approval, reference_document: "") }

      include_examples "does not change record count", PurchaseOrder::Approval
      include_examples "returns an error response"
    end
  end
end
