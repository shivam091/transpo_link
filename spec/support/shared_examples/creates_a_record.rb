# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "creates a record" do |modal|
  it "creates the #{modal.model_name.human.downcase}" do
    expect { subject }.to change(modal, :count).by(1)
  end
end
