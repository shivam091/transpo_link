# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/request_log_spec.rb

require "spec_helper"

RSpec.describe RequestLog, type: :model do
  subject(:request_log) { build(:request_log) }

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:request_logs).optional }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:method).from("get").to("GET") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Navigable) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:cpu_usage) }
    it { is_expected.to apply_scale_to(:elapsed_time) }
  end

  include_examples "apply default scope on created_at:desc"
end
