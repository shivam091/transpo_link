# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/password_validator_spec.rb

require "spec_helper"

RSpec.describe PasswordValidator do
  using RSpec::Parameterized::TableSyntax

  before(:all) do
    class PasswordValidatorModel
      include ActiveModel::Model, ActiveModel::Validations

      attr_accessor :password

      validates :password, password: true
    end
  end

  after(:all) do
    Object.send(:remove_const, :PasswordValidatorModel)
  end

  subject { PasswordValidatorModel.new(password: password) }

  describe "#validate_each" do
    context "when password is valid" do
      where(:password) do
        [
          "Test@123",
          "Secure#456",
          "Strong!Pass1",
          "P@ssword99"
        ]
      end

      with_them do
        it { is_expected.to be_valid }
      end
    end

    context "when password is invalid" do
      where(:password) do
        [
          "test@123",
          "TEST@123",
          "TestTest@123233232223",
          "test",
          "test@",
          "Test@12",
          "Password123",
          "!!!!!!123",
          "TEST@test"
        ]
      end

      with_them do
        it { is_expected.to be_invalid }
      end
    end
  end
end
