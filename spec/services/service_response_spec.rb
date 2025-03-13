# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/service_response_spec.rb

require "spec_helper"

RSpec.describe ServiceResponse do
  describe ".success" do
    let(:service_response) { described_class.success(payload: {key: "value"}) }

    it "returns a success ServiceResponse instance" do
      expect(service_response.status).to eq(:success)
      expect(service_response.payload).to eq({key: "value"})
      expect(service_response.http_status).to eq(:ok)
    end
  end

  describe ".error" do
    let(:service_response) { described_class.error(payload: {key: "value"}, http_status: :unauthorized) }

    it "returns an error ServiceResponse instance" do
      expect(service_response.status).to eq(:error)
      expect(service_response.payload).to eq({key: "value"})
      expect(service_response.http_status).to eq(:unauthorized)
    end
  end

  describe "#success?" do
    context "when status is :success" do
      let(:service_response) { described_class.success }

      it "returns true" do
        expect(service_response.success?).to be_truthy
      end
    end

    context "when status is not :success" do
      let(:service_response) { described_class.error }

      it "returns false" do
        expect(service_response.success?).to be_falsy
      end
    end
  end

  describe "#error?" do
    context "when status is :error" do
      let(:service_response) { described_class.error }

      it "returns true" do
        expect(service_response.error?).to be_truthy
      end
    end

    context "when status is not :error" do
      let(:service_response) { described_class.success }

      it "returns false" do
        expect(service_response.error?).to be_falsy
      end
    end
  end
end
