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
    allow(view_context).to receive(:render).and_call_original
  end

  describe "#partial" do
    it "renders the partial if it exists" do
      allow(view_context.lookup_context).to receive(:exists?).with("existing_partial", [], true).and_return(true)
      expect(view_context).to receive(:render).with("existing_partial", **{}).and_return("rendered_partial")

      expect(renderer.partial("existing_partial")).to eq("rendered_partial")
    end

    it "does not render if the partial does not exist" do
      allow(view_context.lookup_context).to receive(:exists?).with("missing_partial", [], true).and_return(false)

      expect(renderer.partial("missing_partial")).to be_nil
    end
  end

  describe "#template" do
    it "renders the template if it exists" do
      allow(view_context.lookup_context).to receive(:exists?).with("existing_template", [], false).and_return(true)
      expect(view_context).to receive(:render).with(template: "existing_template", **{}).and_return("rendered_template")

      expect(renderer.template("existing_template")).to eq("rendered_template")
    end

    it "does not render if the template does not exist" do
      allow(view_context.lookup_context).to receive(:exists?).with("missing_template", [], false).and_return(false)

      expect(renderer.template("missing_template")).to be_nil
    end
  end
end
