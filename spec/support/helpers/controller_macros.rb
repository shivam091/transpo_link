# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module ControllerMacros
  def with_mock_controller(base_class, name: "MockTest", &block)
    const_name = name.to_s.end_with?("Controller") ? name.to_s : "#{name}Controller"
    logical_name = const_name.sub(/Controller\z/, "").underscore

    # Declare controller_class as a regular local variable
    controller_class = nil

    before(:context) do
      # Create the mock controller class
      controller_class = Class.new(base_class).tap do |klass|
        klass.define_singleton_method(:name) { const_name }

        klass.class_eval(&block)

        klass.define_method(:controller_name) { logical_name }
        klass.define_method(:controller_path) { logical_name }
      end
    end

    before do
      # Stub the constant for each test
      stub_const(const_name, controller_class)

      # Instantiate the controller for each test
      @controller = controller_class.new
    end

    after(:context) do
      # Clean up the constant after the entire spec context
      if Object.const_defined?(const_name)
        Object.send(:remove_const, const_name) if Object.const_get(const_name).is_a?(Class)
      end
    end
  end
end
