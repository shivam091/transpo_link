# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/destroy_service_spec.rb

require "spec_helper"

RSpec.describe Products::DestroyService, type: :service do
  let!(:product) { create(:product) }

  subject(:service_response) { described_class.(product) }

  describe ".call" do
    context "when destroy is successful" do
      include_examples "deletes a record", Product
      include_examples "returns a success response"
    end

    context "when destroy fails" do
      before { allow(product).to receive(:destroy) { false } }

      include_examples "does not change record count", Product
      include_examples "returns an error response"
    end
  end
end
