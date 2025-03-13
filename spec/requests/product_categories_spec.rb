# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"

RSpec.describe "ProductCategories", type: :request do
  let!(:product_category) { create(:product_category) }
  let!(:valid_attributes) { attributes_for(:product_category, name: "New product category") }
  let!(:invalid_attributes) { attributes_for(:product_category, name: "") }

  context "when user is not signed in" do
    describe "GET /product-categories" do
      subject { get product_categories_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /product-categories/new" do
      subject { get new_product_category_path }

      it { is_expected.to require_sign_in }
    end

    describe "POST /product-categories" do
      subject { post product_categories_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /product-categories/:id/edit" do
      subject { get edit_product_category_path(product_category) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /product-categories/:id" do
      subject { put product_category_path(product_category) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /product-categories/:id" do
      subject { delete product_category_path(product_category) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /product-categories" do
      it "renders list of all product categories with pagination" do
        get product_categories_path

        expect(controller_assigns(:product_categories)).to include(product_category)
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
        get edit_product_category_path(product_category)

        expect(controller_assigns(:product_category)).to eq(product_category)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /product-categories/:id" do
      context "when provided attributes are valid" do
        it "updates the product category and redirects" do
          put product_category_path(product_category), params: {product_category: valid_attributes}, as: :turbo_stream

          expect(product_category.reload.name).to eq("New product category")
          expect(response).to redirect_to(product_categories_path)
          expect(flash[:notice]).to eq("Product category was successfully updated.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not update the product category and renders errors" do
          put product_category_path(product_category), params: {product_category: invalid_attributes}, as: :turbo_stream

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
          delete product_category_path(product_category)

          expect(response).to redirect_to(product_categories_path)
          expect(flash[:info]).to eq("Product category was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when delete fails" do
        it "does not delete the product category and redirects with an error message" do
          allow(ProductCategories::DestroyService).to receive(:call) { ServiceResponse.error }

          delete product_category_path(product_category)

          expect(response).to redirect_to(product_categories_path)
          expect(flash[:alert]).to eq("Product category could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
