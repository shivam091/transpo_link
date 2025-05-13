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
    before { get new_product_product_price_path(product), as: :turbo_stream }

    include_examples "initializes a new instance", :product_price, ProductPrice

    it "renders new price tier modal" do
      expect(response.body).to include("<turbo-frame id=\"new_product_price_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /products/:product_id/product-prices" do
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
end
