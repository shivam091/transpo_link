# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order/rejection_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Rejection, type: :model do
  subject(:purchase_order_rejection) { build(:purchase_order_rejection) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order_rejection) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:purchase_order).inverse_of(:rejection) }
  end
end
