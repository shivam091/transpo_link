# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/sql_functions_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::SqlFunctions do
  describe ".lower" do
    let(:value) { "TEST_STRING" }
    let(:quoted_value) { Arel::Nodes.build_quoted(value) }

    context "when column_alias is not provided" do
      it "returns a LOWER SQL function without alias" do
        result = described_class.lower(value)

        expect(result).to be_a(Arel::Nodes::NamedFunction)
        expect(result.name).to eq('LOWER')
        expect(result.expressions).to eq([quoted_value])
      end
    end

    context "when column_alias is provided" do
      let(:column_alias) { 'lowered_value' }

      it "returns a LOWER SQL function with an alias" do
        result = described_class.lower(value, column_alias)

        expect(result).to be_a(Arel::Nodes::As)
        expect(result.left).to be_a(Arel::Nodes::NamedFunction)
        expect(result.left.name).to eq("LOWER")
        expect(result.left.expressions).to eq([quoted_value])
        expect(result.right).to be_a(Arel::Nodes::SqlLiteral)
        expect(result.right).to eq(Arel::Nodes::SqlLiteral.new(column_alias))
      end
    end
  end
end
