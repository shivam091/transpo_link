# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/feedbacks/create_service_spec.rb

require "spec_helper"

RSpec.describe Feedbacks::CreateService, type: :service do
  let!(:user) { create(:buyer) }
  let!(:product) { create(:product) }

  subject(:service_response) { described_class.(user, product, feedback_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:feedback_attributes) { attributes_for(:feedback) }

      include_examples "creates a record", Feedback
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:feedback_attributes) { attributes_for(:feedback, rating: "") }

      include_examples "does not change record count", Feedback
      include_examples "returns an error response"
    end
  end
end
