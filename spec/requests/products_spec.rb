# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/products_spec.rb

require "spec_helper"

RSpec.describe "Products", type: :request do
  let!(:product_category) { create(:product_category) }

  let!(:active_product) { create(:product, :active) }
  let!(:inactive_product) { create(:product) }

  let!(:valid_attributes) { attributes_for(:product, name: "Product", product_category_id: product_category.id) }
  let!(:invalid_attributes) { attributes_for(:product, name: "") }

  context "when user is not signed in" do
    describe "GET /products" do
      subject { get products_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /products/new" do
      subject { get new_product_path }

      it { is_expected.to require_sign_in }
    end

    describe "POST /products" do
      subject { post products_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /products/:id/edit" do
      subject { get edit_product_path(active_product) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /products/:id" do
      subject { put product_path(active_product) }

      it { is_expected.to require_sign_in }
    end

    describe "GET /products/:id" do
      subject { get product_path(active_product) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /products/:id" do
      subject { delete product_path(active_product) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /products" do
      it "renders list of all products with pagination" do
        get products_path

        expect(controller_assigns(:products)).to include(active_product)
        expect(controller_assigns(:products)).to include(inactive_product)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end

      it "renders list of active products with pagination" do
        get active_products_path

        expect(controller_assigns(:products)).to include(active_product)
        expect(controller_assigns(:products)).to exclude(inactive_product)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end

      it "renders list of inactive products with pagination" do
        get inactive_products_path

        expect(controller_assigns(:products)).to include(inactive_product)
        expect(controller_assigns(:products)).to exclude(active_product)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /products/new" do
      before { get new_product_path }

      include_examples "initializes a new instance", :product, Product
    end

    describe "POST /products" do
      context "when provided attributes are valid" do
        it "creates the product and redirects" do
          post products_path, params: {product: valid_attributes}, as: :turbo_stream

          expect(response).to redirect_to(products_path)
          expect(flash[:notice]).to eq("Product was successfully created.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not create the product and renders errors" do
          post products_path, params: {product: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Product could not be created.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_product_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /products/:id/edit" do
      it "renders product edit page" do
        get edit_product_path(active_product)

        expect(controller_assigns(:product)).to eq(active_product)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /products/:id" do
      context "when provided attributes are valid" do
        it "updates the product and redirects" do
          put product_path(active_product), params: {product: valid_attributes}, as: :turbo_stream

          expect(active_product.reload.name).to eq("Product")
          expect(response).to redirect_to(products_path)
          expect(flash[:notice]).to eq("Product was successfully updated.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not update the product and renders errors" do
          put product_path(active_product), params: {product: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Product could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_product_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /products/:id" do
      it "renders product details page" do
        get product_path(active_product)

        expect(controller_assigns(:product)).to eq(active_product)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE /products/:id" do
      context "when valid id" do
        it "deletes the product and redirects" do
          delete product_path(active_product)

          expect(response).to redirect_to(products_path)
          expect(flash[:info]).to eq("Product was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when delete fails" do
        it "does not delete the product and redirects with an error message" do
          allow(Products::DestroyService).to receive(:call) { ServiceResponse.error }

          delete product_path(active_product)

          expect(response).to redirect_to(products_path)
          expect(flash[:alert]).to eq("Product could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
