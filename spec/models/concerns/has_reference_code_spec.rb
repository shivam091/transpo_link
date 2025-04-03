# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/has_reference_code_spec.rb

require "spec_helper"

RSpec.describe HasReferenceCode do
  before(:all) do
    connection.create_table :reference_code_models, force: true do |t|
      t.string :reference_code
      t.timestamps
    end

    class ReferenceCodeModel < ApplicationRecord
      include HasReferenceCode
    end
  end

  after(:all) do
    connection.drop_table :reference_code_models, if_exists: true
    Object.send(:remove_const, :ReferenceCodeModel)
  end

  let(:ref_code_model) { ReferenceCodeModel.new }

  describe "before_create callback" do
    it "calls set_reference_code before creation" do
      expect(ref_code_model).to receive(:set_reference_code)

      ref_code_model.run_callbacks(:create)
    end
  end

  describe "#set_reference_code" do
    context "when reference_code column exists" do
      it "generates a new reference code with correct prefix and sequence" do
        allow(ReferenceCodeModel::REFERENCE_CODE_CONFIG).to receive(:fetch).with("ReferenceCodeModel") { {prefix: "WH", seq_name: "warehouse_reference_code_seq"} }
        allow(connection).to receive(:select_value).with("SELECT nextval('warehouse_reference_code_seq')") { 1 }

        ref_code_model.send(:set_reference_code)

        expect(ref_code_model.reference_code).to eq("WH-0001")
      end
    end

    context "when no existing reference codes are present" do
      it "generates reference code starting from 1" do
        allow(ReferenceCodeModel::REFERENCE_CODE_CONFIG).to receive(:fetch).with("ReferenceCodeModel") { {prefix: "PRD", seq_name: "product_reference_code_seq"} }
        allow(connection).to receive(:select_value).with("SELECT nextval('product_reference_code_seq')") { 1 }

        ref_code_model.send(:set_reference_code)

        expect(ref_code_model.reference_code).to eq("PRD-0001")
      end
    end

    context "when reference_code column does not exist" do
      it "returns false" do
        allow(ReferenceCodeModel).to receive(:column_names) { %w[id] }

        expect(ReferenceCodeModel.new.send(:has_reference_code_column?)).to be_falsy
      end
    end
  end

  describe "constants" do
    it { is_expected.to have_constant(:REFERENCE_CODE_LENGTH) }
    it { is_expected.to have_constant(:REFERENCE_CODE_CONFIG) }
  end

  describe "callbacks" do
    it { expect(ReferenceCodeModel).to have_callback(:before, :create, :set_reference_code) }
  end
end
