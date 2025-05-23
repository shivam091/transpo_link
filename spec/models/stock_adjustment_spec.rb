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

  describe "associations" do
    it { is_expected.to belong_to(:adjustable).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:source).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:inventory).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:user).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:unit).inverse_of(:stock_adjustments) }
  end
end
