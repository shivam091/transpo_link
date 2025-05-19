# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/products/product_prices_spec.rb

require "spec_helper"

RSpec.describe "Products::ProductPrices", type: :request do
  let(:product) { create(:product, :active) }
  let(:product_price) { create(:product_price, product:) }

  let(:valid_params) { {product_price: attributes_for(:product_price, :with_virtual_attributes, unit_id: product.unit_id)} }
  let(:invalid_params) { {product_price: attributes_for(:product_price, min_quantity: nil)} }

  include_context "sign in as admin"

  describe "GET /products/:product_id/product-prices/new" do
    before do
      grant_permission!(admin, :product_prices, :create)
      get new_product_product_price_path(product), as: :turbo_stream
    end

    include_examples "initializes a new instance", :product_price, ProductPrice

    it "renders new price tier modal" do
      expect(response.body).to include("<turbo-frame id=\"new_product_price_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /products/:product_id/product-prices" do
    before { grant_permission!(admin, :product_prices, :create) }

    context "when provided parameters are valid" do
      it "creates the price tier and redirects" do
        post product_product_prices_path(product), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(product)
        expect(flash[:notice]).to eq("Price tier was successfully created.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the price tier and renders errors" do
        post product_product_prices_path(product), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Price tier could not be created.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_product_price_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /products/:product_id/product-prices/:id/edit" do
    it "renders edit price tier modal" do
      grant_permission!(admin, :product_prices, :update)

      get edit_product_product_price_path(product, product_price)

      expect(controller_assigns(:product_price)).to eq(product_price)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /products/:product_id/product-prices/:id" do
    before { grant_permission!(admin, :product_prices, :update) }

    context "when provided parameters are valid" do
      it "updates the price tier and redirects" do
        put product_product_price_path(product, product_price), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(product)
        expect(flash[:notice]).to eq("Price tier was successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the price tier and renders errors" do
        put product_product_price_path(product, product_price), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Price tier could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_product_price_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /products/:product_id/product-prices/:id" do
    before { grant_permission!(admin, :product_prices, :delete) }

    context "when deletion is successful" do
      it "deletes the price tier and redirects" do
        delete product_product_price_path(product, product_price), as: :turbo_stream

        expect(response).to redirect_to(product)
        expect(flash[:info]).to eq("Price tier was successfully deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when deletion is unsuccessful" do
      it "does not delete the price tier and redirects with an error message" do
        allow(Products::DestroyService).to receive(:call) { ServiceResponse.error }

        delete product_product_price_path(product, product_price), as: :turbo_stream

        expect(response).to redirect_to(product)
        expect(flash[:alert]).to eq("Price tier could not be deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
