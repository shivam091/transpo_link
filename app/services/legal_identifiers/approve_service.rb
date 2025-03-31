# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiers::ApproveService < ApplicationService
  def initialize(legal_identifier)
    @legal_identifier = legal_identifier
  end

  def call
    approve_legal_identifier
  end

  private

  attr_reader :legal_identifier

  def approve_legal_identifier
    if legal_identifier.approve!
      ServiceResponse.success(payload: {legal_identifier:})
    else
      ServiceResponse.error(payload: {legal_identifier:})
    end
  end
end
