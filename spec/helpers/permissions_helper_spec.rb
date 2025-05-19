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
end
