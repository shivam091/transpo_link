# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/migration_helpers_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::MigrationHelpers do
  let!(:dummy_class) { Class.new { extend TranspoLink::MigrationHelpers } }
  let!(:enum_name) { "business_categories" }

  describe "#enum_values" do
    before do
      allow(connection).to receive(:execute) {
        [
          {"enumlabel" => "small"},
          {"enumlabel" => "medium"},
          {"enumlabel" => "large"}
        ]
      }
    end

    it "returns a comma-separated string of quoted enum values" do
      result = dummy_class.enum_values(enum_name)

      expect(result).to eq("'small', 'medium', 'large'")
    end

    it "queries the correct SQL statement" do
      query = <<-SQL
        SELECT enumlabel
        FROM pg_enum
        JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
        WHERE typname = '#{enum_name}'
      SQL

      expect(connection).to receive(:execute).with(query)

      dummy_class.enum_values(enum_name)
    end

    it "returns an empty string when no values are found" do
      allow(connection).to receive(:execute) { [] }
      result = dummy_class.enum_values(enum_name)

      expect(result).to eq("")
    end
  end
end
