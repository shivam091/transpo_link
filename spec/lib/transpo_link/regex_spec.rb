# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/regex_spec.rb

require "spec_helper"

describe TranspoLink::Regex do
  using RSpec::Parameterized::TableSyntax

  describe ".strong_password_regex" do
    subject { described_class.strong_password_regex }

    where(:password, :is_valid) do
      "Test@123"           | true
      "Test@1234"          | true
      "test@123"           | false
      "test"               | false
      "test@"              | false
      "Test@12"            | false
    end

    with_them do
      it do
        if is_valid
          expect(password).to match(subject)
        else
          expect(password).not_to match(subject)
        end
      end
    end
  end

  describe ".email_regex" do
    subject { described_class.email_regex }

    where(:email, :is_valid) do
      "admin@transpo-link.com"       | true
      "admin@transpo-link.co.uk"     | true
      "Abc"                    | false
      "ABC"                    | false
      "abC"                    | false
    end

    with_them do
      it do
        if is_valid
          expect(email).to match(subject)
        else
          expect(email).not_to match(subject)
        end
      end
    end
  end
end
