# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/errors/application_error_spec.rb

require "spec_helper"

RSpec.describe ApplicationError do
  let(:error) { described_class.new(:unknown, context: {foo: "bar"}) }

  describe "#initialize" do
    it "sets the i18n_key" do
      expect(error.i18n_key).to eq(:unknown)
    end

    it "sets the context" do
      expect(error.context).to eq({foo: "bar"})
    end
  end

  describe "#message" do
    it "returns a translated message using default scope" do
      allow(I18n).to receive(:t).with(:unknown, scope: "errors", foo: "bar") { "Translated message" }

      expect(error.message).to eq("Translated message")
    end
  end
end
