# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/application_service_spec.rb

require "spec_helper"

RSpec.describe ApplicationService do
  describe ".call" do
    let(:dummy_service_class) do
      Class.new(ApplicationService) do
        def initialize(param, &block)
          @param = param
          @block = block
        end

        def call
          result = :service_result
          @block.call(@param) if block_given?

          result
        end
      end
    end

    let(:param) { :test_param }

    it "instantiates a new instance and calls #call" do
      service_instance = instance_double(dummy_service_class, call: :service_result)

      expect(dummy_service_class).to receive(:new).with(param) { service_instance }
      expect(service_instance).to receive(:call)

      result = dummy_service_class.call(param)
      expect(result).to eq(:service_result)
    end

    it "yields the block if given" do
      yielded = nil

      result = dummy_service_class.call(param) do |value|
        yielded = value
      end

      expect(result).to eq(:service_result)
      expect(yielded).to eq(param)
    end
  end
end
