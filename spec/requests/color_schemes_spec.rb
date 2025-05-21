# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/color_schemes_spec.rb

require "spec_helper"

RSpec.describe "ColorSchemes", type: :request do
  let(:valid_params) { {color_scheme: "dark"} }
  let(:invalid_params) { {color_scheme: "rainbow"} }

  include_context "sign in as buyer"

  describe "PUT|PATCH /color_scheme" do
    before { grant_permission!(buyer, :preferences, :update) }

    context "when valid color scheme is passed" do
      it "updates the user's color scheme and returns success JSON" do
        patch color_scheme_path, params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(parsed_response_body["color_scheme"]).to eq("dark")
        expect(parsed_response_body["icon"]).to eq("moon")
      end
    end

    context "when invalid color scheme is passed" do
      it "returns an bad_request error" do
        patch color_scheme_path, params: invalid_params, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response_body["error"]).to eq("Invalid color scheme")
      end
    end

    context "when update fails due to validation error" do
      before { allow_any_instance_of(User).to receive(:update) { false } }

      it "returns an unprocessable_entity error" do
        patch color_scheme_path, params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response_body["error"]).to eq("Failed to update the color scheme")
      end
    end
  end
end
