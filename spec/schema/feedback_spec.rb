# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/feedback_spec.rb

require "spec_helper"

RSpec.describe Feedback, type: :model do
  subject(:feedback) { build(:feedback) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:reviewable_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:reviewable_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:rating).of_type(:decimal) }
    it { is_expected.to have_db_column(:comment).of_type(:text) }
    it { is_expected.to have_db_column(:is_unread).of_type(:boolean).with_options(default: true) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:is_unread) }
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index([:reviewable_type, :reviewable_id]) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_feedbacks_user_id_on_users).on_delete(:nullify) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_feedbacks_rating_half_step).with_expression("(rating * 2.0) = floor(rating * 2.0)") }
    it { is_expected.to have_check_constraint(:check_feedbacks_comment_length).with_expression("char_length(comment) <= 1000 AND char_length(comment) > 0") }
    it { is_expected.to have_check_constraint(:check_feedbacks_comment_presence).with_expression("comment IS NOT NULL AND comment <> ''::text") }
    it { is_expected.to have_check_constraint(:check_feedbacks_rating_range).with_expression("rating >= 0.0 AND rating <= 10.0") }
    it { is_expected.to have_check_constraint(:check_feedbacks_rating_presence).with_expression("rating IS NOT NULL") }
  end
end
