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

  describe "after_initialize callback" do
    it "calls set_reference_code if required" do
      ref_code_model = ReferenceCodeModel.new
      expect(ref_code_model.reference_code).not_to be_blank
    end
  end

  describe "#set_reference_code" do
    it "generates a random alphanumeric reference code" do
      ref_code_model = ReferenceCodeModel.new
      expect(ref_code_model.reference_code).to match(/^[A-Z0-9]{10}$/)
    end

    it "does not override an existing reference code" do
      ref_code_model = ReferenceCodeModel.new(reference_code: "CUSTOM1234")
      expect(ref_code_model.reference_code).to eq("CUSTOM1234")
    end
  end

  describe "#has_reference_code_column?" do
    it "returns true when the column exists" do
      expect(ReferenceCodeModel.new.send(:has_reference_code_column?)).to be_truthy
    end

    context "when reference_code column does not exist" do
      before do
        allow(ReferenceCodeModel).to receive(:column_names).and_return(%w[id])
      end

      it "returns false" do
        expect(ReferenceCodeModel.new.send(:has_reference_code_column?)).to be_falsy
      end
    end
  end

  describe "#code_required?" do
    it "returns false when reference_code is already set" do
      ref_code_model = ReferenceCodeModel.new(reference_code: "ABC123")
      expect(ref_code_model.send(:code_required?)).to be_falsy
    end
  end
end
