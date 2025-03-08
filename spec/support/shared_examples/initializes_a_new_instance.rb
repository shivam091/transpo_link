# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "initializes a new instance" do |object_name, model|
  it "initializes a new #{model.model_name.name} instance" do
    expect(controller_assigns(object_name)).to be_a_new(model)
    expect(response).to have_http_status(:ok)
  end
end
