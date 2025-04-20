# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/color_schemes_spec.rb

require "spec_helper"

RSpec.describe "ColorSchemes", type: :request do
  include_context "sign in as buyer"

  describe "PUT|PATCH /color_scheme" do
    let(:headers) { {"ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json"} }

    context "when valid color scheme" do
      it "updates the user's color scheme and returns success JSON" do
        patch color_scheme_path, params: {color_scheme: "dark"}.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        expect(buyer.reload.user_preference.preferred_color_scheme).to eq("dark")
        expect(parsed_response_body["preferred_color_scheme"]).to eq("dark")
        expect(parsed_response_body["icon"]).to eq("moon")
      end
    end

    context "when invalid color scheme" do
      it "returns an unprocessable_entity error" do
        patch color_scheme_path, params: {color_scheme: "rainbow"}.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response_body["error"]).to eq("Invalid color scheme")
      end
    end

    context "when update fails" do
      before do
        allow_any_instance_of(UserPreference).to receive(:update!) { false }
      end

      it "returns an error message" do
        patch color_scheme_path, params: {color_scheme: "light"}.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response_body["error"]).to eq("Failed to update the color scheme")
      end
    end
  end
end
