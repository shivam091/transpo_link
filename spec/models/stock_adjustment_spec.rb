# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/stock_adjustment_spec.rb

require "spec_helper"

RSpec.describe StockAdjustment, type: :model do
  subject(:stock_adjustment) { build(:stock_adjustment) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:stock_adjustment) }
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:adjustment_type).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:adjustment_reason).backed_by_column_of_type(:enum) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:adjusted_quantity) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:adjustable).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:source).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:inventory).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:user).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:unit).inverse_of(:stock_adjustments) }
  end
end
