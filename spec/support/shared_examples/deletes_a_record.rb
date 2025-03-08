# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "deletes a record" do |model|
  it "deletes the #{model.model_name.human.downcase}" do
    expect { subject }.to change(model, :count).by(-1)
  end
end
