# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/sql_functions_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::SqlFunctions do
  let(:table) { Arel::Table.new(:inventory_batches) }
  let(:select_manager) do
    Arel::SelectManager.new(Arel::Table.engine).tap do |select_manager|
      select_manager.project(expr).from(table)
    end
  end
  
  describe ".lower" do
    let(:value) { "TEST_STRING" }
    let(:quoted_value) { Arel::Nodes.build_quoted(value) }

    context "when column_alias is not provided" do
      let(:result) { described_class.lower(value) }

      it "returns a LOWER SQL function without alias" do
        expect(result).to be_a(Arel::Nodes::NamedFunction)
        expect(result.name).to eq('LOWER')
        expect(result.expressions).to eq([quoted_value])
      end
    end

    context "when column_alias is provided" do
      let(:column_alias) { 'lowered_value' }
      let(:result) { described_class.lower(value, column_alias) }

      it "returns a LOWER SQL function with an alias" do
        expect(result).to be_a(Arel::Nodes::As)
        expect(result.left).to be_a(Arel::Nodes::NamedFunction)
        expect(result.left.name).to eq("LOWER")
        expect(result.left.expressions).to eq([quoted_value])
        expect(result.right).to be_a(Arel::Nodes::SqlLiteral)
        expect(result.right).to eq(Arel::Nodes::SqlLiteral.new(column_alias))
      end
    end
  end

  describe ".avg" do
    let(:value) { :rating }
    let(:arel_value) { Arel::Nodes::SqlLiteral.new(value.to_s) }

    context "when column_alias is not provided" do
      let(:result) { described_class.avg(value.to_s) }

      it "returns an AVG SQL function without alias" do
        expect(result).to be_a(Arel::Nodes::NamedFunction)
        expect(result.name).to eq("AVG")
        expect(result.expressions).to eq([arel_value])
      end
    end

    context "when column_alias is provided" do
      let(:column_alias) { "average_rating" }
      let(:result) { described_class.avg(value.to_s, column_alias) }

      it "returns an AVG SQL function with an alias" do
        expect(result).to be_a(Arel::Nodes::As)
        expect(result.left).to be_a(Arel::Nodes::NamedFunction)
        expect(result.left.name).to eq("AVG")
        expect(result.left.expressions).to eq([arel_value])
        expect(result.right).to be_a(Arel::Nodes::SqlLiteral)
        expect(result.right).to eq(Arel::Nodes::SqlLiteral.new(column_alias))
      end
    end
  end

  describe ".sum" do
    context "when column_alias is not provided" do
      let(:expr) { described_class.sum(table[:quantity]) }

      it "generates correct SUM SQL fragment" do
        expect(select_manager.to_sql).to match(
          /SELECT SUM\("inventory_batches"\."quantity"\) FROM "inventory_batches"/i
        )
      end
    end

    context "when column_alias is provided" do
      let(:expr) { described_class.sum(table[:quantity], "total_quantity") }

      it "generates correct SUM SQL fragment with column alias" do
        expect(select_manager.to_sql).to match(
          /SELECT SUM\("inventory_batches"\."quantity"\) AS total_quantity FROM "inventory_batches"/i
        )
      end
    end
  end

  describe ".mul" do
    let(:expr) { described_class.mul(table[:cost_price], table[:quantity]) }

    it "generates correct multiplication SQL fragment" do
      expect(select_manager.to_sql).to match(
        /SELECT \"inventory_batches\".\"cost_price\" \* \"inventory_batches\".\"quantity\" FROM \"inventory_batches\"/i
      )
    end
  end

  describe ".sum_mul" do
    context "when column_alias is not provided" do
      let(:expr) { described_class.sum_mul(table[:cost_price], table[:quantity]) }

      it "generates correct SUM of multiplication SQL fragment" do
        expect(select_manager.to_sql).to match(
          /SELECT SUM\("inventory_batches"\."cost_price" \* "inventory_batches"\."quantity"\) FROM "inventory_batches"/i
        )
      end
    end

    context "when column_alias is provided" do
      let(:expr) { described_class.sum_mul(table[:cost_price], table[:quantity], "total_cost") }

      it "generates correct aliased SUM of multiplication SQL fragment" do
        expect(select_manager.to_sql).to match(
          /SELECT SUM\("inventory_batches"\."cost_price" \* "inventory_batches"\."quantity"\) AS total_cost FROM "inventory_batches"/i
        )
      end
    end
  end
end
