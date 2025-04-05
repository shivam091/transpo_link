# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/migrations/20250130103139_create_roles_spec.rb

require "spec_helper"
require_migration!

RSpec.describe CreateRoles do
  let(:table_name) { Role.table_name }
  let(:col_definitions) { column_definitions(table_name) }

  describe ".up" do
    before do
      run_migration(:down)
      run_migration(:up)
    end

    it "creates the table" do
      expect(table_exists?(table_name)).to be_truthy
    end

    it "has the correct columns" do
      expect(column_names(table_name)).to contain_exactly("id", "name", "is_active", "created_at", "updated_at")
    end

    it "has the correct check constraints" do
      expect(constraint_names(table_name)).to include([
        "check_roles_name_presence",
        "check_roles_name_length"
      ])
    end

    it "has the correct indexes" do
      expect(index_names(table_name)).to include("index_roles_on_name")
    end

    it "has the correct columns definitions" do
      expect(col_definitions["id"].sql_type).to eq("uuid")
      expect(col_definitions["name"].sql_type).to eq("character varying")

      expect(col_definitions["is_active"].sql_type).to eq("boolean")
      expect(col_definitions["is_active"].default).to eq("false")

      %w[created_at updated_at].each do |column|
        expect(col_definitions[column].sql_type).to eq("timestamp with time zone")
        expect(col_definitions[column].null).to be_falsy
      end
    end

    it "has no foreign keys" do
      expect(foreign_key_columns(table_name)).to be_empty
    end

    it "defaults is_active to false" do
      connection.execute(<<~SQL)
        INSERT INTO #{table_name}
          (name, created_at, updated_at)
        VALUES
          ('Test Role', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      SQL

      result = connection.select_value(<<~SQL)
        SELECT is_active FROM #{table_name} WHERE name = 'Test Role'
      SQL

      expect(result).to be_falsy
    end

    it "enforces unique constraint on name" do
      connection.execute(<<~SQL)
        INSERT INTO #{table_name}
          (name, created_at, updated_at)
        VALUES
          ('Admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      SQL

      expect {
        connection.execute(<<~SQL)
          INSERT INTO #{table_name}
            (name, created_at, updated_at)
          VALUES
            ('Admin', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "validates name length using check constraint" do
      expect {
        connection.execute(<<~SQL)
          INSERT INTO #{table_name}
            (name, created_at, updated_at)
          VALUES
            ('A', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      }.to raise_error(ActiveRecord::StatementInvalid)

      expect {
        connection.execute(<<~SQL)
          INSERT INTO #{table_name}
            (name, created_at, updated_at)
          VALUES
            ('#{'A' * 56}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "validates name presence using check constraint" do
      expect {
        connection.execute(<<~SQL)
          INSERT INTO
            #{table_name}
          (name, created_at, updated_at)
          VALUES
          (NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      }.to raise_error(ActiveRecord::StatementInvalid)

      expect {
        connection.execute(<<~SQL)
          INSERT INTO #{table_name}
            (name, created_at, updated_at)
          VALUES
            ('', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe ".down" do
    before { run_migration(:down) }

    it "drops the roles table" do
      expect(connection.table_exists?(table_name)).to be_falsy
    end
  end
end
