# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/devise_spec.rb

require "spec_helper"

RSpec.describe "Devise configuration for TranspoLink" do
  before { load_file("config/initializers/devise.rb") }

  describe "secret key configuration" do
    it "sets the secret key from credentials" do
      expect(Devise.secret_key).to eq(Rails.application.credentials.config[:SECRET_KEY_BASE])
    end
  end

  describe "mailer configuration" do
    it "sets the mailer sender from credentials" do
      expect(Devise.mailer_sender).to eq(Rails.application.credentials.config[:SENDGRID_SENDER])
    end

    it "sets the custom mailer class" do
      expect(Devise.mailer).to eq(DeviseMailer)
    end
  end

  describe "authentication keys configuration" do
    it "sets case insensitive keys" do
      expect(Devise.case_insensitive_keys).to include(:email)
    end

    it "sets strip whitespace keys" do
      expect(Devise.strip_whitespace_keys).to include(:email)
    end
  end

  describe "session storage configuration" do
    it "skips session storage for HTTP auth" do
      expect(Devise.skip_session_storage).to include(:http_auth)
    end
  end

  describe "password configuration" do
    it "sets password length range" do
      expect(Devise.password_length).to eq(8..20)
    end
  end

  describe "timeoutable configuration" do
    it "sets the timeout duration" do
      expect(Devise.timeout_in).to be_eql(10.minutes)
    end
  end

  describe "lockable configuration" do
    it "sets lock strategy to failed attempts" do
      expect(Devise.lock_strategy).to eq(:failed_attempts)
    end

    it "sets maximum attempts before locking" do
      expect(Devise.maximum_attempts).to eq(3)
    end

    it "sets unlock strategy to email" do
      expect(Devise.unlock_strategy).to eq(:email)
    end
  end

  describe "recoverable configuration" do
    it "sets reset password keys to email" do
      expect(Devise.reset_password_keys).to include(:email)
    end

    it "sets reset password within time limit" do
      expect(Devise.reset_password_within).to eq(3.hours)
    end
  end

  describe "confirmable configuration" do
    it "sets confirmation keys to email" do
      expect(Devise.confirmation_keys).to include(:email)
    end

    it "requires confirmation within 1 day" do
      expect(Devise.confirm_within).to eq(1.day)
    end
  end

  describe "rememberable configuration" do
    it "sets remember period to 2 weeks" do
      expect(Devise.remember_for).to eq(2.weeks)
    end

    it "expires all remember me tokens on sign out" do
      expect(Devise.expire_all_remember_me_on_sign_out).to be_truthy
    end
  end

  describe "sign in/out configuration" do
    it "does not sign in after reset password" do
      expect(Devise.sign_in_after_reset_password).to be_falsy
    end

    it "does not sign in automatically after password change" do
      expect(Devise.sign_in_after_change_password).to be_falsy
    end
  end
end
