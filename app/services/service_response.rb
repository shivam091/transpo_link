# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ServiceResponse
  attr_reader :status, :http_status, :payload

  def initialize(status:, payload: {}, http_status: nil)
    self.status = status
    self.payload = payload
    self.http_status = http_status
  end

  class << self
    def success(payload: {}, http_status: :ok)
      new(status: :success, payload:, http_status:)
    end

    def error(payload: {}, http_status: :unprocessable_entity)
      new(status: :error, payload:, http_status:)
    end
  end

  def success?
    status == :success
  end

  def error?
    status == :error
  end

  # === Hooks ===

  def on_success
    yield self if success?

    self
  end

  def on_error
    yield self if error?

    self
  end

  private

  attr_writer :status, :http_status, :payload
end
