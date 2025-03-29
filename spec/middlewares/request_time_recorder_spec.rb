# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/middlewares/request_time_recorder_spec.rb

require "spec_helper"

RSpec.describe RequestTimeRecorder do
  let(:app) { ->(env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { {} }

  describe "#call" do
    it "records the request start time in the env" do
      travel_to(Time.current) do
        middleware.call(env)
        expect(env["REQUEST_STARTED_AT"]).to eq(Time.now.utc)
      end
    end

    it "does not modify the app response" do
      status, headers, response = middleware.call(env)

      expect(status).to eq(200)
      expect(headers).to eq({"Content-Type" => "text/plain"})
      expect(response).to eq(["OK"])
    end

    it "sets the request time before calling the app" do
      expect(app).to receive(:call).with(hash_including("REQUEST_STARTED_AT")).and_call_original

      middleware.call(env)
    end
  end
end
