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
    context "when column_alias is not provided" do
      let(:expr) { described_class.lower(table[:batch_number]) }

      it "generates correct LOWER SQL fragment" do
        expect(select_manager.to_sql).to match(
          /SELECT LOWER\(\"inventory_batches\".\"batch_number\"\) FROM \"inventory_batches\"/i
        )
      end
    end

    context "when column_alias is provided" do
      let(:expr) { described_class.lower(table[:batch_number], "lower_batch_number") }

      it "generates correct LOWER SQL fragment with column alias" do
        expect(select_manager.to_sql).to match(
          /SELECT LOWER\(\"inventory_batches\".\"batch_number\"\) AS lower_batch_number FROM \"inventory_batches\"/i
        )
      end
    end
  end

  describe ".avg" do
    context "when column_alias is not provided" do
      let(:expr) { described_class.avg(table[:quantity]) }

      it "generates correct AVG SQL fragment" do
        expect(select_manager.to_sql).to match(
          /SELECT AVG\(\"inventory_batches\".\"quantity\"\) FROM \"inventory_batches\"/i
        )
      end
    end

    context "when column_alias is provided" do
      let(:expr) { described_class.avg(table[:quantity], "average_quantity") }

      it "generates correct AVG SQL fragment with column alias" do
        expect(select_manager.to_sql).to match(
          /SELECT AVG\(\"inventory_batches\".\"quantity\"\) AS average_quantity FROM \"inventory_batches\"/i
        )
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
