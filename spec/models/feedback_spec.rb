# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/feedback_spec.rb

require "spec_helper"

RSpec.describe Feedback, type: :model do
  subject(:feedback) { build(:feedback) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:feedback) }
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
    it { is_expected.to include_module(Navigable) }
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

  include_examples "apply default scope on created_at:desc"

  describe "class methods and scopes" do
    let(:reviewable) { create(:product) }

    let!(:user1) { create(:buyer) }
    let!(:user2) { create(:admin) }

    let!(:feedback1) { create(:feedback, user: user1, rating: 7.0, is_unread: true, reviewable:) }
    let!(:feedback2) { create(:feedback, user: user2, rating: 9.5, is_unread: false, reviewable:) }

    describe ".accessible" do
      it "returns all feedbacks for admin user" do
        expect(described_class.accessible(user2)).to match_array([feedback1, feedback2])
      end

      it "returns own feedbacks for users other than admin" do
        expect(described_class.accessible(user1)).to include(feedback1)
      end
    end

    describe ".unread_for_user" do
      it "returns only unread feedbacks for the given user" do
        expect(described_class.unread_for_user(user1)).to include(feedback1)
        expect(described_class.unread_for_user(user2)).to be_empty
      end
    end

    describe ".unread" do
      it "returns only unread feedbacks" do
        expect(described_class.unread).to include(feedback1)
        expect(described_class.unread).to exclude(feedback2)
      end
    end

    describe ".read" do
      it "returns only read feedbacks" do
        expect(described_class.read).to include(feedback2)
        expect(described_class.read).to exclude(feedback1)
      end
    end

    describe ".average_rating_for" do
      let!(:feedback3) { create(:feedback, user: user1, rating: 6.0, is_unread: true, reviewable:) }
      let!(:feedback4) { create(:feedback, user: user2, rating: 8.0, is_unread: false, reviewable:) }

      it "calculates the average rating for a product" do
        expect(described_class.average_rating_for(reviewable)).to eq(7.6) # (7.0 + 9.5 + 6.0 + 8.0) / 4 = 7.625 -> rounded to 7.6
      end
    end

    describe ".for_user_and_reviewable" do
      it "returns feedback given by a specific user for a reviewable" do
        expect(described_class.for_user_and_reviewable(user1, reviewable)).to include(feedback1)
      end

      it "returns an empty array if no feedback exists for the user and reviewable" do
        expect(described_class.for_user_and_reviewable(user1, create(:product))).to be_empty
      end
    end
  end

  describe "instance methods" do
    describe "#mark_as_read!" do
      let!(:feedback) { create(:feedback) }

      it "marks feedback as read" do
        feedback.mark_as_read!

        expect(feedback.reload.is_unread?).to be_falsy
      end
    end

    describe "#key_associations" do
      let!(:feedback) { create(:feedback) }

      it "returns array of key associations" do
        expect(feedback.key_associations).to eq([feedback.user, feedback.reviewable])
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
