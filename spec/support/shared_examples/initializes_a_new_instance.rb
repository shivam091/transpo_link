# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "initializes a new instance" do |object_name, klass|
  it "initializes a new #{klass.model_name.name.downcase}" do
    expect(controller_assigns(object_name)).to be_a_new(klass)
    expect(response).to have_http_status(:ok)
  end
end
