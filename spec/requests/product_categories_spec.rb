# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"

RSpec.describe "ProductCategories", type: :request do
  let!(:active_product_category) { create(:product_category, :active) }
  let!(:inactive_product_category) { create(:product_category) }

  let(:valid_attributes) { attributes_for(:product_category, name: "New product category") }
  let(:invalid_attributes) { attributes_for(:product_category, name: "") }

  include_context "sign in as admin"

  describe "GET /product-categories" do
    it "renders list of all product categories with pagination" do
      get product_categories_path

      expect(controller_assigns(:product_categories)).to include(active_product_category)
      expect(controller_assigns(:product_categories)).to include(inactive_product_category)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of active product categories with pagination" do
      get active_product_categories_path

      expect(controller_assigns(:product_categories)).to include(active_product_category)
      expect(controller_assigns(:product_categories)).to exclude(inactive_product_category)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of inactive product categories with pagination" do
      get inactive_product_categories_path

      expect(controller_assigns(:product_categories)).to include(inactive_product_category)
      expect(controller_assigns(:product_categories)).to exclude(active_product_category)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /product-categories/new" do
    before { get new_product_category_path }

    include_examples "initializes a new instance", :product_category, ProductCategory
  end

  describe "POST /product-categories" do
    context "when provided attributes are valid" do
      it "creates the product category and redirects" do
        post product_categories_path, params: {product_category: valid_attributes}, as: :turbo_stream

        expect(response).to redirect_to(product_categories_path)
        expect(flash[:notice]).to eq("Product category was successfully created.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not create the product category and renders errors" do
        post product_categories_path, params: {product_category: invalid_attributes}, as: :turbo_stream

        expect(flash[:alert]).to eq("Product category could not be created.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_product_category_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /product-categories/:id/edit" do
    it "renders product category edit page" do
      get edit_product_category_path(active_product_category)

      expect(controller_assigns(:product_category)).to eq(active_product_category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /product-categories/:id" do
    context "when provided attributes are valid" do
      it "updates the product category and redirects" do
        expect {
          put product_category_path(active_product_category), params: {product_category: valid_attributes}, as: :turbo_stream
        }.to change { active_product_category.reload.name }.to("New product category")

        expect(response).to redirect_to(product_categories_path)
        expect(flash[:notice]).to eq("Product category was successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not update the product category and renders errors" do
        expect {
          put product_category_path(active_product_category), params: {product_category: invalid_attributes}, as: :turbo_stream
        }.to not_change { active_product_category.reload.name }

        expect(flash[:alert]).to eq("Product category could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_product_category_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /product-categories/:id" do
    context "when valid id" do
      it "deletes the product category and redirects" do
        delete product_category_path(active_product_category)

        expect(response).to redirect_to(product_categories_path)
        expect(flash[:info]).to eq("Product category was successfully deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when delete fails" do
      it "does not delete the product category and redirects with an error message" do
        allow(ProductCategories::DestroyService).to receive(:call) { ServiceResponse.error }

        delete product_category_path(active_product_category)

        expect(response).to redirect_to(product_categories_path)
        expect(flash[:alert]).to eq("Product category could not be deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
