# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/migrations/20250130102317_enable_uuid_spec.rb

require "spec_helper"
require_migration!

RSpec.describe EnableUuid do
  let(:extension_name) { "pgcrypto" }

  describe ".up" do
    before do
      run_migration(:down)
      run_migration(:up)
    end

    it "enables the extension" do
      expect(connection.extension_enabled?(extension_name)).to be_truthy
    end
  end

  describe ".down" do
    before { run_migration(:down) }

    it "disables the extension" do
      expect(connection.extension_enabled?(extension_name)).to be_falsy
    end
  end
end
