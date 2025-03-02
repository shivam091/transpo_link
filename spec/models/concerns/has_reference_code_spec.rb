# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/has_reference_code_spec.rb

require "spec_helper"

RSpec.describe HasReferenceCode do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :reference_code_models, force: true do |t|
        t.string :reference_code
        t.timestamps
      end
    end

    class ReferenceCodeModel < ApplicationRecord
      include HasReferenceCode
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:reference_code_models, if_exists: true)
    Object.send(:remove_const, :ReferenceCodeModel)
  end

  describe "before_create callback" do
    it "calls set_reference_code before creation" do
      ref_code_model = ReferenceCodeModel.new
      expect(ref_code_model).to receive(:set_reference_code)
      ref_code_model.run_callbacks(:create)
    end
  end

  describe "#set_reference_code" do
    context "when reference_code column exists" do
      before do
        allow(ReferenceCodeModel).to receive(:unscope) { ReferenceCodeModel }
        allow(ReferenceCodeModel).to receive(:maximum).with(:reference_code) { "XX-00010" }
      end

      it "generates a new reference code" do
        ref_code_model = ReferenceCodeModel.new
        ref_code_model.send(:set_reference_code)
        expect(ref_code_model.reference_code).to eq("XX-00011")
      end
    end

    context "when no existing reference codes are present" do
      before do
        allow(ReferenceCodeModel).to receive(:unscope) { ReferenceCodeModel }
        allow(ReferenceCodeModel).to receive(:maximum).with(:reference_code){ nil }
      end

      it "starts from 1" do
        ref_code_model = ReferenceCodeModel.new
        ref_code_model.send(:set_reference_code)
        expect(ref_code_model.reference_code).to eq("XX-00001")
      end
    end

    context "when reference_code column does not exist" do
      before do
        allow(ReferenceCodeModel).to receive(:column_names) { %w[id] }
      end

      it "does not set reference_code" do
        ref_code_model = ReferenceCodeModel.new
        ref_code_model.send(:set_reference_code)
        expect(ref_code_model.reference_code).to be_nil
      end
    end
  end

  describe "#has_reference_code_column?" do
    context "when column exists" do
      it "returns true" do
        expect(ReferenceCodeModel.new.send(:has_reference_code_column?)).to be_truthy
      end
    end

    context "when column does not exist" do
      before do
        allow(ReferenceCodeModel).to receive(:column_names) { %w[id] }
      end

      it "returns false" do
        expect(ReferenceCodeModel.new.send(:has_reference_code_column?)).to be_falsy
      end
    end
  end
end
