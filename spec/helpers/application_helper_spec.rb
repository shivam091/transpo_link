# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/application_helper_spec.rb

require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
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
    let!(:controller_mock) { double(controller_name: "orders", controller_path: "orders") }

    before { allow(helper).to receive(:controller) { controller_mock } }

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
      expect(helper.humanize_boolean(true)).to eq("Yes")
    end

    it "returns 'No' when false" do
      expect(helper.humanize_boolean(false)).to eq("No")
    end

    it "returns 'Nothing' when nil" do
      expect(helper.humanize_boolean(nil)).to eq("Nothing")
    end
  end
end
