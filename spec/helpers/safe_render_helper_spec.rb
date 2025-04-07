# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/safe_render_helper_spec.rb

require "spec_helper"

RSpec.describe SafeRenderHelper, type: :helper do
  describe "#safe_render" do
    it "returns an instance of SafeRenderer" do
      expect(helper.safe_render).to be_a(SafeRenderHelper::SafeRenderer)
    end
  end
end

RSpec.describe SafeRenderHelper::SafeRenderer do
  let(:lookup_context) { ActionView::LookupContext.new(ActionController::Base.view_paths) }
  let(:view_context) do
    ActionView::Base.with_empty_template_cache.new(lookup_context, {}, ApplicationController.new)
  end
  let(:renderer) { described_class.new(view_context) }

  before do
    # Allow render to work on the view context
    allow(view_context).to receive(:render)
  end

  describe "#partial" do
    it "renders the partial if it exists" do
      allow(view_context.lookup_context).to receive(:exists?).with("existing_partial", [], true) { true }
      expect(view_context).to receive(:render).with("existing_partial", **{}) { "rendered_partial" }

      expect(renderer.partial("existing_partial")).to eq("rendered_partial")
    end

    it "does not render if the partial does not exist" do
      allow(view_context.lookup_context).to receive(:exists?).with("missing_partial", [], true) { false }

      expect(renderer.partial("missing_partial")).to be_nil
    end
  end

  describe "#template" do
    it "renders the template if it exists" do
      allow(view_context.lookup_context).to receive(:exists?).with("existing_template", [], false) { true }
      expect(view_context).to receive(:render).with(template: "existing_template", **{}) { "rendered_template" }

      expect(renderer.template("existing_template")).to eq("rendered_template")
    end

    it "does not render if the template does not exist" do
      allow(view_context.lookup_context).to receive(:exists?).with("missing_template", [], false) { false }

      expect(renderer.template("missing_template")).to be_nil
    end
  end

  describe "#json" do
    let(:json_object) { {message: "Hello, JSON!"} }

    before do
      allow(view_context).to receive(:render).with(json: json_object, **{}) { json_object.to_json }
    end

    it "renders JSON if request format is json" do
      allow(view_context).to receive(:request) { double(format: double(symbol: :json)) }

      expect(renderer.json(json_object)).to eq(json_object.to_json)
    end

    it "does not render JSON if request format is not json" do
      allow(view_context).to receive(:request) { double(format: double(symbol: :html)) }

      expect(renderer.json(json_object)).to be_nil
    end

    it "falls back and renders if request format check raises error" do
      allow(view_context).to receive(:request).and_raise(NoMethodError)
      allow(view_context).to receive(:render).with(json: json_object, **{}) { json_object.to_json }

      expect(renderer.json(json_object)).to eq(json_object.to_json)
    end
  end

  describe "#xml" do
    let(:xml_object) { {message: "Hello, XML!"} }

    before do
      allow(view_context).to receive(:render).with(xml: xml_object, **{}) { xml_object.to_xml }
    end

    it "renders XML if request format is xml" do
      allow(view_context).to receive(:request) { double(format: double(symbol: :xml)) }

      expect(renderer.xml(xml_object)).to eq(xml_object.to_xml)
    end

    it "does not render XML if request format is not xml" do
      allow(view_context).to receive(:request) { double(format: double(symbol: :html)) }

      expect(renderer.xml(xml_object)).to be_nil
    end

    it "falls back and renders if request format check raises error" do
      allow(view_context).to receive(:request).and_raise(NoMethodError)
      allow(view_context).to receive(:render).with(xml: xml_object, **{}) { xml_object.to_xml }

      expect(renderer.xml(xml_object)).to eq(xml_object.to_xml)
    end
  end

  describe "#render_format?" do
    let(:renderer) { described_class.new(view_context) }

    it "returns true if an exception is raised (rescue fallback)" do
      allow(view_context).to receive(:respond_to?).with(:render) { true }
      allow(view_context).to receive(:respond_to?).with(:request) { true }
      allow(view_context).to receive(:respond_to?) do |method_name, *_args|
        [:render, :request].include?(method_name)
      end

      # Simulate an exception being raised when accessing the request
      allow(view_context).to receive(:request).and_raise(StandardError)

      # We don't care what format we pass; it should rescue and return true
      expect(renderer.send(:render_format?, :json)).to be_truthy
    end
  end

  describe "#lookup_context" do
    context "with invalid context" do
      let(:invalid_context) { Object.new }
      let(:renderer) { described_class.new(invalid_context) }

      it "raises an error when context lacks both lookup_context and view_context" do
        expect {
          renderer.partial("existing_partial")
        }.to raise_error(RuntimeError, /SafeRenderer needs a context that responds to `lookup_context`/)
      end
    end

    describe "lookup_context fallback to view_context (real classes)" do
      let(:controller_context) do
        double("Controller").tap do |controller|
          allow(controller).to receive(:view_context) { view_context }
          allow(controller).to receive(:render) do |*args, **kwargs, &block|
            controller.view_context.render(*args, **kwargs, &block)
          end
          allow(controller).to receive(:request) { view_context.request }
        end
      end
      let(:renderer) { described_class.new(controller_context) }

      it "uses view_context.lookup_context and renders partial" do
        allow(view_context.lookup_context).to receive(:exists?).with("shared/test_partial", [], true) { true }
        allow(view_context).to receive(:render).with("shared/test_partial", **{}) { "rendered partial" }

        expect(renderer.partial("shared/test_partial")).to eq("rendered partial")
      end
    end
  end
end
