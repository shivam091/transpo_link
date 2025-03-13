# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/middlewares/request_logger_spec.rb

require "spec_helper"

RSpec.describe RequestLogger do
  let!(:app) { -> (env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let!(:middleware) { described_class.new(app) }
  let!(:env) do
    {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/test",
      "QUERY_STRING" => "param=value",
      "rack.input" => StringIO.new,
      "HTTP_USER_AGENT" => "RSpec",
      "HTTP_REFERER" => "http://example.com",
      "HTTP_ORIGIN" => "http://example.com",
      "REMOTE_ADDR" => "127.0.0.1",
      "rack.session" => instance_double(ActionDispatch::Request::Session, id: "test_session"),
      "warden" => instance_double(Warden::Proxy, user: create(:admin)), # Stubbing Warden
      "REQUEST_STARTED_AT" => Time.now.utc
    }
  end

  before do
    allow(Time).to receive(:now) { Time.utc(2025, 1, 1, 12, 0, 0) } # Freeze time
    allow(RequestLog).to receive(:create!) # Stub DB call
  end

  describe "#call" do
    it "calls the next middleware in the stack" do
      status, headers, response = middleware.call(env)

      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("text/plain")
      expect(response).to eq(["OK"])
    end

    it "filters headers correctly" do
      middleware = described_class.new(app)

      status, headers, body = middleware.call(env)

      expect(headers).to include("Content-Type" => "text/plain")
      expect(headers).to exclude("Authorization")
    end
  end

  describe "#memory_usage" do
    it "fetches memory usage" do
      allow(middleware).to receive(:`).with("ps -o rss= -p #{Process.pid}") { "1024" }

      expect(middleware.send(:memory_usage)).to eq(1024)
    end
  end

  describe "#cpu_usage" do
    it "fetches CPU usage" do
      allow(middleware).to receive(:`).with("ps -o %cpu= -p #{Process.pid}") { 3.5 }

      expect(middleware.send(:cpu_usage)).to eq(3.5)
    end
  end

  describe "#response_size" do
    it "calculates response size correctly" do
      response = ["Hello", "World"]
      expect(middleware.send(:response_size, response)).to eq(10)
    end
  end

  describe "#http_status_for" do
    it "returns 404 for ActiveRecord::RecordNotFound" do
      exception = ActiveRecord::RecordNotFound.new("Record not found")
      status = described_class.new(nil).send(:http_status_for, exception)

      expect(status).to eq(404)
    end

    it "returns 500 for StandardError" do
      exception = StandardError.new("Something went wrong")
      status = described_class.new(nil).send(:http_status_for, exception)

      expect(status).to eq(500)
    end

    it "returns 403 for ActionController::InvalidAuthenticityToken" do
      exception = ActionController::InvalidAuthenticityToken.new("Invalid authenticity token")
      status = described_class.new(nil).send(:http_status_for, exception)

      expect(status).to eq(403)
    end

    it "returns 422 for ActiveRecord::RecordInvalid" do
      exception = ActiveRecord::RecordInvalid.new(User.new)
      status = described_class.new(app).send(:http_status_for, exception)

      expect(status).to eq(422)
    end

    it "returns 500 for unknown exceptions" do
      exception = NoMethodError.new("Unknown method")

      status = described_class.new(nil).send(:http_status_for, exception)

      expect(status).to eq(500) # or whatever default you want for unknown exceptions
    end
  end

  describe "#format_exception_response" do
    it "formats exception" do
      expect(
        middleware.send(:format_exception_response, NoMethodError.new("Unknown method"))
      ).to eq({backtrace: nil, error: "NoMethodError", message: "Unknown method"})
    end
  end

  describe "#filter_headers" do
    it "filters headers" do
      expect(
        middleware.send(:filter_headers, env)
      ).to eq({"Origin"=>"http://example.com", "Referer"=>"http://example.com", "User-Agent"=>"RSpec"})
    end
  end
end
