# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "does not change record count" do |model|
  it "does not change the number of #{model.model_name.human.downcase.pluralize}" do
    expect { subject }.to not_change(model, :count)
  end
end
