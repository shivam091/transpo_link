# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/middlewares/ip_info_spec.rb

RSpec.describe IpInfo do
  let(:app) { ->(env) { [200, env, "OK"] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { {} }

  # Mocking the IPinfo::IPinfo object returned by IPinfo.create
  let(:mock_ipinfo_instance) { instance_double(IPinfo::IPinfo) }

  # Mocking the structure returned by the details method
  let(:mock_details) { double("IPinfo", all: { ip: "192.168.1.1", city: "New York", country: "US" }) }

  before do
    # Stub Rails credentials for API key
    allow(Rails.application.credentials).to receive(:config).and_return({ IP_LOOKUP_API_KEY: "fake_api_key" })

    # Stub IPinfo.create to return the mock_ipinfo_instance
    allow(IPinfo).to receive(:create).with("fake_api_key", {}).and_return(mock_ipinfo_instance)

    # Stub the details method to return mock_details
    allow(mock_ipinfo_instance).to receive(:details).and_return(mock_details)
  end

  describe "#call" do
    it "adds IP information to the env" do
      status, headers, response = middleware.call(env)

      expect(status).to eq(200)
      expect(env["ipinfo"]).to eq({ ip: "192.168.1.1", city: "New York", country: "US" })
      expect(response).to eq("OK")
    end
  end

  describe "IPinfo API interaction" do
    it "initializes IPinfo with the API key" do
      expect(IPinfo).to receive(:create).with("fake_api_key", {}).and_return(mock_ipinfo_instance)
      middleware.call(env)
    end

    it "calls the details method on the IPinfo instance" do
      expect(mock_ipinfo_instance).to receive(:details).and_return(mock_details)
      middleware.call(env)
    end
  end
end
