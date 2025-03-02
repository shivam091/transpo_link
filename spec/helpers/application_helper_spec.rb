# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/application_helper_spec.rb

require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#render_if_exists" do
    it "renders the partial if it exists" do
      allow(helper).to receive(:partial_exists?).with("existing_partial") { true }
      expect(helper).to receive(:render).with("existing_partial", {}) { "rendered_partial" }
      expect(helper.render_if_exists("existing_partial")).to eq("rendered_partial")
    end

    it "does not render if the partial does not exist" do
      allow(helper).to receive(:partial_exists?).with("missing_partial") { false }
      expect(helper.render_if_exists("missing_partial")).to be_nil
    end
  end

  describe "#partial_exists?" do
    it "returns true if partial exists" do
      allow(helper.lookup_context).to receive(:exists?).with("existing_partial", [], true) { true }
      expect(helper.partial_exists?("existing_partial")).to be_truthy
    end

    it "returns false if partial does not exist" do
      allow(helper.lookup_context).to receive(:exists?).with("missing_partial", [], true) { false }
      expect(helper.partial_exists?("missing_partial")).to be_falsy
    end
  end

  describe "#template_exists?" do
    it "returns true if template exists" do
      allow(helper.lookup_context).to receive(:exists?).with("existing_template", [], false) { true }
      expect(helper.template_exists?("existing_template")).to be_truthy
    end

    it "returns false if template does not exist" do
      allow(helper.lookup_context).to receive(:exists?).with("missing_template", [], false) { false }
      expect(helper.template_exists?("missing_template")).to be_falsy
    end
  end

  describe "#copyright_year" do
    it "returns the current year if start and end year are the same" do
      allow(Date).to receive(:current) { Date.new(2025) }
      expect(helper.copyright_year).to eq(2025)
    end

    it "returns a range if the years differ" do
      allow(Date).to receive(:current) { Date.new(2027) }
      expect(helper.copyright_year).to eq("2025 - 2027")
    end
  end

  describe "#active_when" do
    it "returns 'active' when condition is true" do
      expect(helper.active_when(true)).to eq("active")
    end

    it "returns nil when condition is false" do
      expect(helper.active_when(false)).to be_nil
    end
  end

  describe "#current_controller?" do
    before do
      allow(helper).to receive(:controller) { double(controller_name: "orders", controller_path: "orders") }
    end

    it "returns true if current controller matches" do
      expect(helper.current_controller?(:orders)).to be_truthy
    end

    it "returns false if current controller does not match" do
      expect(helper.current_controller?(:invoices)).to be_falsy
    end
  end

  describe "#current_action?" do
    before do
      allow(helper).to receive(:action_name) { "new" }
    end

    it "returns true if current action matches" do
      expect(helper.current_action?(:new)).to be_truthy
    end

    it "returns false if current action does not match" do
      expect(helper.current_action?(:create)).to be_falsy
    end
  end

  describe "#humanize_boolean" do
    it "returns 'Yes' when true" do
      allow(I18n).to receive(:t).with("boolean.yes") { "Yes" }

      expect(helper.humanize_boolean(true)).to eq("Yes")
    end

    it "returns 'No' when false" do
      allow(I18n).to receive(:t).with("boolean.no") { "No" }

      expect(helper.humanize_boolean(false)).to eq("No")
    end

    it "returns 'Nothing' when nil" do
      allow(I18n).to receive(:t).with("boolean.nil") { "Nothing" }

      expect(helper.humanize_boolean(nil)).to eq("Nothing")
    end
  end
end
