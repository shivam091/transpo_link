# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/stock_adjustments/create_service_spec.rb

require "spec_helper"

RSpec.describe StockAdjustments::CreateService, type: :service do
  let(:user) { create(:admin) }

  let!(:adjustable) { create(:inventory) }

  subject(:service_response) { described_class.(adjustable, stock_adjustment_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:stock_adjustment_attributes) { attributes_for(:stock_adjustment, unit_id: adjustable.unit_id, user_id: user.id) }

      include_examples "creates a record", StockAdjustment
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:stock_adjustment_attributes) { attributes_for(:stock_adjustment) }

      include_examples "does not change record count", StockAdjustment
      include_examples "returns an error response"
    end
  end
end
