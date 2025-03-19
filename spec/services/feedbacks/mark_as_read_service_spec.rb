# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/feedbacks/mark_as_read_service_spec.rb

require "spec_helper"

RSpec.describe Feedbacks::MarkAsReadService, type: :service do
  let!(:feedback) { create(:feedback) }

  subject(:service_response) { described_class.(feedback) }

  describe ".call" do
    context "when mark as read is successful" do
      it "marks feedback as read" do
        expect(service_response.payload[:feedback].is_unread?).to be_falsy
      end

      include_examples "returns a success response"
    end

    context "when mark as read fails" do
      before { allow(feedback).to receive(:mark_as_read!) { false } }

      it "does not mark feedback as read" do
        expect(service_response.payload[:feedback].is_unread?).to be_truthy
      end

      include_examples "returns an error response"
    end
  end
end
