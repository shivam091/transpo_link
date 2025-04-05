# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/migrations/20250201095137_create_enum_color_schemes_spec.rb

require "spec_helper"
require_migration!
require_migration! "create_user_preferences"

RSpec.describe CreateEnumColorSchemes do
  let(:enum_name) { "color_schemes" }

  describe ".up" do
    before do
      ActiveRecord::Migration.suppress_messages do
        CreateUserPreferences.migrate(:down)
      end
      run_migration(:down)
      run_migration(:up)
    end

    it "creates the color_schemes enum" do
      expect(enum_type_exists?(enum_name)).to be_truthy
    end

    it "returns the list of valid values" do
      expect(enum_values(enum_name)).to eq(["auto", "dark", "light"])
    end
  end

  describe ".down" do
    before { run_migration(:down) }

    it "drops the color_schemes enum" do
      expect(enum_type_exists?(enum_name)).to be_falsy
    end
  end
end
