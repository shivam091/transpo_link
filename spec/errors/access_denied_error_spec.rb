# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/errors/access_denied_error_spec.rb

require "spec_helper"

RSpec.describe AccessDeniedError do
  let(:module_key) { :orders }
  let(:action_key) { :create }
  let(:error) { described_class.new(module_key, action_key) }

  it "inherits from ApplicationError" do
    expect(error).to be_a(ApplicationError)
  end

  it "has the correct i18n_key and context" do
    expect(error.i18n_key).to eq(:access_denied)
    expect(error.context).to eq({module_key: :orders, action_key: :create})
  end

  it "returns a translated message" do
    allow(I18n).to receive(:t).with(:access_denied, scope: "errors", module_key: :orders, action_key: :create) { "Access denied to module: orders, action: create" }

    expect(error.message).to eq("Access denied to module: orders, action: create")
  end
end
