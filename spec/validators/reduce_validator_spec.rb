# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/reduce_validator_spec.rb

require "spec_helper"

RSpec.describe ReduceValidator do
  before(:all) do
    class ReduceValidatorModel
      include ActiveModel::Model, ActiveModel::Validations

      attr_accessor :attribute

      validates :attribute,
                length: {maximum: 5},
                format: {with: /[\d]+/},
                reduce: true
    end
  end

  after(:all) do
    Object.send(:remove_const, :ReduceValidatorModel)
  end

  subject { ReduceValidatorModel.new }

  describe "#validates_each" do
    context "when there are multiple errors on the attribute" do
      before do
        subject.attribute = "invalid value"
        subject.valid?
        subject.errors.add(:attribute, "second error message")
      end

      it "reduces the errors to a single error message" do
        expect(subject.errors[:attribute].size).to eq(2)

        ReduceValidator.new(attributes: :attribute).validate(subject)

        expect(subject.errors[:attribute].size).to eq(1)
        expect(subject.errors[:attribute].first).to eq("is too long (maximum is 5 characters)")
      end
    end

    context "when there is a single error on the attribute" do
      before do
        subject.attribute = "invalid value"
        subject.valid?
      end

      it "does not change the error message" do
        expect(subject.errors[:attribute].size).to eq(1)

        ReduceValidator.new(attributes: :attribute).validate(subject)

        expect(subject.errors[:attribute].size).to eq(1)
        expect(subject.errors[:attribute].first).to eq("is too long (maximum is 5 characters)")
      end
    end
  end
end
