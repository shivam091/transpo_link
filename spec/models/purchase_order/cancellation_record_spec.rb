# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order/cancellation_record_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::CancellationRecord, type: :model do
  subject(:po_cancellation) { build(:po_cancellation) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:po_cancellation) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:reason).backed_by_column_of_type(:enum) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:cancellable).inverse_of(:cancellation_record) }
    it { is_expected.to belong_to(:user).inverse_of(:cancellation_records) }
  end
end
