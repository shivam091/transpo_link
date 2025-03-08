# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "returns a success response" do |klass|
  it "returns a success response" do
    expect(service_response).to be_a(ServiceResponse)
    expect(service_response).to be_success
  end
end
