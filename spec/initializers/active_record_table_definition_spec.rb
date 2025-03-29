# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/active_record_table_definition_spec.rb

require "spec_helper"

RSpec.describe ActiveRecord::ConnectionAdapters::TableDefinition do
  let(:table_definition) { described_class.new(connection, :test_table) }

  describe "#timestamps_with_timezone" do
    let(:default_value) { Arel.sql("NOW()") }

    it "adds created_at and updated_at columns with timestamptz type" do
      expect(table_definition).to receive(:column).with(:created_at, :timestamptz, null: false)
      expect(table_definition).to receive(:column).with(:updated_at, :timestamptz, null: false)

      table_definition.timestamps_with_timezone null: false
    end

    it "respects passed options" do
      expect(table_definition).to receive(:column).with(:created_at, :timestamptz, null: true, default: default_value)
      expect(table_definition).to receive(:column).with(:updated_at, :timestamptz, null: true, default: default_value)

      table_definition.timestamps_with_timezone null: true, default: default_value
    end
  end
end
