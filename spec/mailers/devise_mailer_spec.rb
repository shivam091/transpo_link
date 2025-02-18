# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/mailers/devise_mailer_spec.rb

require "spec_helper"

RSpec.describe DeviseMailer, type: :mailer do
  let(:user) { create(:admin) }
  let(:token) { "dummy-token" }
  let(:options) { {} }

  describe "#confirmation_instructions" do
    it "does not send an email" do
      mail = described_class.confirmation_instructions(user, token, options)
      expect(mail).to be_a(ActionMailer::MessageDelivery)
      expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  describe "#reset_password_instructions" do
    it "does not send an email" do
      mail = described_class.reset_password_instructions(user, token, options)
      expect(mail).to be_a(ActionMailer::MessageDelivery)
      expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  describe "#unlock_instructions" do
    it "does not send an email" do
      mail = described_class.unlock_instructions(user, token, options)
      expect(mail).to be_a(ActionMailer::MessageDelivery)
      expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  describe "#email_changed" do
    it "does not send an email" do
      mail = described_class.email_changed(user, options)
      expect(mail).to be_a(ActionMailer::MessageDelivery)
      expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  describe "#password_change" do
    it "does not send an email" do
      mail = described_class.password_change(user, options)
      expect(mail).to be_a(ActionMailer::MessageDelivery)
      expect { mail.deliver_now }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end
end
