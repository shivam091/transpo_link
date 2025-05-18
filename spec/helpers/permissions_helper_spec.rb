# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/permissions_helper_spec.rb

require "spec_helper"

RSpec.describe PermissionsHelper, type: :helper do
  describe "#translate_module" do
    it "returns translated module name from permissions.modules scope" do
      expect(I18n).to receive(:t).with("users", scope: "permissions.modules") { "Users" }
      expect(helper.translate_module("users")).to eq("Users")
    end

    it "returns fallback string if translation is missing" do
      allow(I18n).to receive(:t).with("non_existent_key", scope: "permissions.modules") { "permissions.modules.non_existent_key" }

      expect(helper.translate_module("non_existent_key")).to eq("permissions.modules.non_existent_key")
    end
  end

  describe "#translate_action" do
    it "returns translated action name from permissions.actions scope" do
      expect(I18n).to receive(:t).with("create", scope: "permissions.actions") { "Create" }
      expect(helper.translate_action("create")).to eq("Create")
    end

    it "returns fallback string if translation is missing" do
      allow(I18n).to receive(:t).with("unknown_action", scope: "permissions.actions") { "permissions.actions.unknown_action" }

      expect(helper.translate_action("unknown_action")).to eq("permissions.actions.unknown_action")
    end
  end

  describe "#authorized_for?" do
    let(:user) { build_stubbed(:user) }
    let(:ability) { instance_double("Ability") }

    before do
      allow(helper).to receive(:current_user) { user }
      allow(Ability).to receive(:new).with(user) { ability }
    end

    context "when user has permission" do
      it "returns true" do
        allow(ability).to receive(:can?).with("orders", "update") { true }

        expect(helper.authorized_for?("orders", "update")).to be_truthy
      end
    end

    context "when user does not have permission" do
      it "returns false" do
        allow(ability).to receive(:can?).with("orders", "delete") { false }

        expect(helper.authorized_for?("orders", "delete")).to be_falsy
      end
    end
  end

  describe "#with_permission" do
    let(:user) { build_stubbed(:user) }
    let(:ability) { instance_double("Ability") }

    before do
      allow(helper).to receive(:current_user) { user }
      allow(Ability).to receive(:new).with(user) { ability }
    end

    context "when user is authorized for given module and action" do
      it "executes the given block" do
        allow(ability).to receive(:can?).with("orders", "edit") { true }

        expect { |b| helper.with_permission("orders", "edit", &b) }.to yield_control
      end
    end

    context "when user is not authorized for given module and action" do
      it "does not execute the given block" do
        allow(ability).to receive(:can?).with("orders", "edit") { false }

        expect { |b| helper.with_permission("orders", "edit", &b) }.not_to yield_control
      end
    end
  end
end
