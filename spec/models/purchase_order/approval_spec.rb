# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order/approval_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Approval, type: :model do
  subject(:purchase_order_approval) { build(:purchase_order_approval) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order_approval) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:remarks) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:reference_document) }
    it { is_expected.to sanitize_attribute(:remarks) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:purchase_order).inverse_of(:approval) }
  end
end
