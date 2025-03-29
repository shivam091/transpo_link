# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/states_spec.rb

require "spec_helper"

RSpec.describe "States", type: :request do
  describe "GET /states" do
    let(:country_code) { "US" }
    let(:states) { [["California", "CA"], ["New York", "NY"]] }

    context "when country_code is provided" do
      it "returns a list of states for country_code" do
        allow(TranspoLink::CountryInfo).to receive(:new).with(country_code) { double(select_subdivision_options: states) }

        get states_path, params: {country_code: country_code}, as: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"state-select\">")
        expect(response.body).to include("California").and include("New York")
      end
    end

    context "when no country_code is provided" do
      it "returns an empty state list" do
        get states_path, as: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"state-select\">")
        expect(response.body).to include("No states available")
      end
    end
  end
end
