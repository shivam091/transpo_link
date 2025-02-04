# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# <%= rspec_path %>

require "spec_helper"

RSpec.describe <%= normalized_class_name %>Service, type: :service do
  context "doing something" do
    describe ".call" do
      it "should test something" do
        skip
      end
    end
  end
end
