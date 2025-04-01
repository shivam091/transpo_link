# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/feedback_spec.rb

require "spec_helper"

RSpec.describe Feedback, type: :model do
  subject { create(:feedback) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:feedback) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
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

    it { is_expected.to have_db_index(:is_unread) }
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index([:reviewable_type, :reviewable_id]) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_feedbacks_user_id_on_users).on_delete(:nullify) }

    it { is_expected.to have_check_constraint(:check_feedbacks_rating_step).with_expression("(rating * 2.0) = floor(rating * 2.0)") }
    it { is_expected.to have_check_constraint(:check_feedbacks_comment_length).with_expression("char_length(comment) <= 1000 AND char_length(comment) > 0") }
    it { is_expected.to have_check_constraint(:check_feedbacks_comment_presence).with_expression("comment IS NOT NULL AND comment <> ''::text") }
    it { is_expected.to have_check_constraint(:check_feedbacks_rating_numericality).with_expression("rating >= 0.0 AND rating <= 10.0") }
    it { is_expected.to have_check_constraint(:check_feedbacks_rating_presence).with_expression("rating IS NOT NULL") }
  end

  describe "default values" do
    let(:feedback) { described_class.new }

    it "should set true as default value for #is_unread" do
      expect(feedback.is_unread).to be_truthy
    end
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Sanitizable) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:comment) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:feedbacks) }
    it { is_expected.to belong_to(:reviewable).inverse_of(:feedbacks) }
  end

  describe "validations" do
    describe "#rating" do
      it { is_expected.to validate_presence_of(:rating) }
      it { is_expected.to validate_numericality_of(:rating).is_in(0..10) }
    end

    describe "#comment" do
      it { is_expected.to validate_presence_of(:comment) }
      it { is_expected.to validate_length_of(:comment).is_at_most(1000) }
    end
  end

  describe "Scopes" do
    let!(:unread_feedback) { create(:feedback) }
    let!(:read_feedback) { create(:feedback, :read) }

    describe ".unread" do
      it "returns only unread feedbacks" do
        expect(described_class.unread).to include(unread_feedback)
        expect(described_class.unread).to exclude(read_feedback)
      end
    end

    describe ".read" do
      it "returns only read feedbacks" do
        expect(described_class.read).to include(read_feedback)
        expect(described_class.read).to exclude(unread_feedback)
      end
    end
  end

  include_examples "apply default scope on created_at:desc"

  describe "class methods" do
    let!(:user1) { create(:buyer) }
    let!(:user2) { create(:buyer) }
    let!(:product) { create(:product) }

    let!(:feedback1) { create(:feedback, user: user1, reviewable: product, rating: 7.0, is_unread: true) }
    let!(:feedback2) { create(:feedback, user: user2, reviewable: product, rating: 9.5, is_unread: false) }
    let!(:feedback3) { create(:feedback, user: user1, reviewable: product, rating: 6.0, is_unread: true) }
    let!(:feedback4) { create(:feedback, user: user2, reviewable: product, rating: 8.0, is_unread: false) }

    describe ".accessible" do
      it "returns list of accessible feedbacks" do
        expect(described_class.accessible(subject.user)).to include(subject)
      end
    end

    describe ".unread_for_user" do
      it "returns only unread feedbacks for the given user" do
        expect(described_class.unread_for_user(user1)).to match_array([feedback1, feedback3])
        expect(described_class.unread_for_user(user2)).to be_empty
      end
    end

    describe ".average_rating_for" do
      it "calculates the average rating for a product" do
        expect(described_class.average_rating_for(product)).to eq(7.6) # (7.0 + 9.5 + 6.0 + 8.0) / 4 = 7.625 -> rounded to 7.6
      end
    end

    describe ".for_user_and_reviewable" do
      it "returns feedback given by a specific user for a product" do
        expect(described_class.for_user_and_reviewable(user1, product)).to match_array([feedback1, feedback3])
      end

      it "returns an empty array if no feedback exists for the user and reviewable" do
        expect(described_class.for_user_and_reviewable(user1, create(:product))).to be_empty
      end
    end
  end

  describe "instance methods" do
    describe "#mark_as_read!" do
      it "marks feedback as read" do
        subject.mark_as_read!

        expect(subject.reload.is_unread?).to be_falsy
      end
    end

    describe "#rating_in_valid_steps" do
      let(:feedback) { build(:feedback, rating: rating) }

      context "when rating is in step of 0.5" do
        where(:rating) { [0, 0.5, 1, 1.5, 5, 9.5, 10] }

        with_them do
          it { expect(feedback).to be_valid }
        end
      end

      context "when rating is not in step of 0.5" do
        where(:rating) { [0.1, 1.3, 2.7, 4.9, 9.8] }

        with_them do
          it { expect(feedback).to be_invalid }
        end
      end
    end
  end
end
