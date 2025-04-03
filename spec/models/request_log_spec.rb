# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/request_log_spec.rb

require "spec_helper"

RSpec.describe RequestLog, type: :model do
  subject { build(:request_log) }

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:uuid).of_type(:string) }
    it { is_expected.to have_db_column(:uri).of_type(:string) }
    it { is_expected.to have_db_column(:method).of_type(:string) }
    it { is_expected.to have_db_column(:session_id).of_type(:string) }
    it { is_expected.to have_db_column(:session_private_id).of_type(:string) }
    it { is_expected.to have_db_column(:remote_address).of_type(:inet) }
    it { is_expected.to have_db_column(:elapsed_time).of_type(:decimal).with_options(precision: 10, scale: 4, default: 0.0) }
    it { is_expected.to have_db_column(:user_agent).of_type(:string) }
    it { is_expected.to have_db_column(:referrer).of_type(:string) }
    it { is_expected.to have_db_column(:exception).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:request_headers).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:response_headers).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:status).of_type(:integer) }
    it { is_expected.to have_db_column(:response_size).of_type(:integer) }
    it { is_expected.to have_db_column(:query_params).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:ip_info).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:origin).of_type(:string) }
    it { is_expected.to have_db_column(:memory_usage).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:cpu_usage).of_type(:decimal).with_options(precision: 5, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:uuid).unique }
    it { is_expected.to have_db_index(:session_id) }
    it { is_expected.to have_db_index(:remote_address) }
    it { is_expected.to have_db_index(:ip_info) }
    it { is_expected.to have_db_index(:query_params) }
    it { is_expected.to have_db_index(:exception) }
    it { is_expected.to have_db_index(:request_headers) }
    it { is_expected.to have_db_index(:response_headers) }
    it { is_expected.to have_db_index(:user_id) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_request_logs_user_id_on_users).on_delete(:nullify) }

    it { is_expected.to have_check_constraint(:check_request_logs_uuid_presence).with_expression("uuid IS NOT NULL AND uuid::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_request_logs_uri_presence).with_expression("uri IS NOT NULL AND uri::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_request_logs_method_presence).with_expression("method IS NOT NULL AND method::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_request_logs_remote_address_presence).with_expression("remote_address IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_request_logs_ip_info_presence).with_expression("ip_info IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_request_logs_method_in_uppercase).with_expression("upper(method::text) = method::text") }
  end

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
  end

  include_examples "apply default scope on created_at:desc"
end
