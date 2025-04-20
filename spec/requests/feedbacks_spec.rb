# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/feedbacks_spec.rb

require "spec_helper"

RSpec.describe "Feedbacks", type: :request do
  let!(:unread_feedback) { create(:feedback) }
  let!(:read_feedback) { create(:feedback, :read) }

  let(:reviewable) { unread_feedback.reviewable }
  let(:valid_attributes) { attributes_for(:feedback, rating: 0.5) }
  let(:invalid_attributes) { attributes_for(:feedback, rating: nil) }

  include_context "sign in as admin"

  describe "GET /feedbacks" do
    it "renders list of all feedbacks with pagination" do
      get feedbacks_path

      expect(controller_assigns(:feedbacks)).to include(read_feedback)
      expect(controller_assigns(:feedbacks)).to include(unread_feedback)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of read feedbacks with pagination" do
      get read_feedbacks_path

      expect(controller_assigns(:feedbacks)).to include(read_feedback)
      expect(controller_assigns(:feedbacks)).to exclude(unread_feedback)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of unread feedbacks with pagination" do
      get unread_feedbacks_path

      expect(controller_assigns(:feedbacks)).to include(unread_feedback)
      expect(controller_assigns(:feedbacks)).to exclude(read_feedback)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /feedbacks/new" do
    before { get new_product_feedback_path(reviewable) }

    include_examples "initializes a new instance", :feedback, Feedback
  end

  describe "POST /feedbacks" do
    context "when provided attributes are valid" do
      it "creates the feedback and redirects" do
        post product_feedbacks_path(reviewable), params: {feedback: valid_attributes}, headers: {"HTTP_REFERER" => root_path}, as: :turbo_stream

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Your feedback helps us improve. Thanks for being a part of our community!")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not create the feedback and renders errors" do
        post product_feedbacks_path(reviewable), params: {feedback: invalid_attributes}, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem submitting your feedback. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_feedback_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT|PATCH /feedbacks/:id/mark-as-read" do
    context "when unread feedback" do
      it "marks feedback as read and redirects" do
        expect {
          put mark_as_read_feedback_path(unread_feedback), headers: {"HTTP_REFERER" => root_path}, as: :turbo_stream
        }.to change { unread_feedback.reload.is_unread? }.to be_falsy

        expect(response).to redirect_to(root_path)
        expect(flash[:info]).to eq("Feedback was successfully marked as read.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when read feedback" do
      it "does not mark feedback as read and redirects with an error message" do
        expect {
          put mark_as_read_feedback_path(read_feedback), headers: {"HTTP_REFERER" => root_path}, as: :turbo_stream
        }.to not_change { unread_feedback.reload.is_unread? }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("We encountered a problem marking the feedback as read. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "GET /feedbacks/:id" do
    it "renders feedback details page" do
      get feedback_path(read_feedback)

      expect(controller_assigns(:feedback)).to eq(read_feedback)
      expect(response).to have_http_status(:ok)
    end
  end
end
