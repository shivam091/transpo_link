# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/regex_spec.rb

require "spec_helper"

describe TranspoLink::Regex do
  using RSpec::Parameterized::TableSyntax

  describe "::STRONG_PASSWORD_REGEX" do
    let(:strong_password_regex) { described_class::STRONG_PASSWORD_REGEX }

    context "when password is valid" do
      where(:password) do
        [
          "Test@123" ,
          "Test@1234"
        ]
      end

      with_them do
        it { expect(password).to match(strong_password_regex) }
      end
    end

    context "when password is invalid" do
      where(:password) do
        [
          "test@123",
          "test",
          "test@",
          "Test@12",
        ]
      end

      with_them do
        it { expect(password).to_not match(strong_password_regex) }
      end
    end
  end

  describe "::EMAIL_REGEX" do
    let(:email_regex) { described_class::EMAIL_REGEX }

    context "when email is valid" do
      where(:email) do
        [
          "admin@transpo-link.com",
          "admin@transpo-link.co.uk"
        ]
      end

      with_them do
        it { expect(email).to match(email_regex) }
      end
    end

    context "when email is invalid" do
      where(:email) do
        [
          "Abc",
          "ABC",
          "abC"
        ]
      end

      with_them do
        it { expect(email).to_not match(email_regex) }
      end
    end
  end
end
