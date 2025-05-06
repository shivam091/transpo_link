# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/current_spec.rb

require "spec_helper"

RSpec.describe Current do
  let(:user) { create(:buyer) }

  after { described_class.reset }

  describe ".user" do
    context "when user is assigned" do
      before { described_class.user = user }

      it "returns the assigned user" do
        expect(described_class.user).to eq(user)
      end
    end

    context "when user is not assigned" do
      it "returns nil" do
        expect(described_class.user).to be_nil
      end
    end
  end

  describe ".reset" do
    before { described_class.user = user }

    it "clears the current attributes" do
      expect {
        described_class.reset
      }.to change {
        described_class.user
      }.from(user).to(nil)
    end
  end
end
