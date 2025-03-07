# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/email_validator_spec.rb

require "spec_helper"

RSpec.describe EmailValidator do
  using RSpec::Parameterized::TableSyntax

  subject do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      attr_accessor :email

      validates :email, email: true

      def self.model_name
        ActiveModel::Name.new(self, nil, "EmailValidatorModel")
      end
    end.new(email: email)
  end

  describe "#validate_each" do
    context "when email is valid" do
      where(:email) do
      [
        "admin@transpo-link.com",
        "admin@transpo-link.co.uk",
        "user.name+tag@example.com",
        "valid_email123@example.org",
        "valid.email@sub.domain.net",
        "valid-email@domain.io",
      ]
    end

      with_them do
        it { is_expected.to be_valid }
      end
    end

    context "when email is invalid" do
      where(:email) do
        [
          "Abc",
          "ABC",
          "abC",
          "plainaddress",
          "@missingusername.com",
          "username@",
          "user@.com",
          "user@com",
          "user@domain.c",
          "user@example.com.",
          "user@example@domain.com",
          "user name@example.com",
          "user<name>@example.com"
        ]
      end

      with_them do
        it { is_expected.to be_invalid }
      end
    end
  end
end
