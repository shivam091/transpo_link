# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiers::RejectService < ApplicationService
  def initialize(legal_identifier)
    @legal_identifier = legal_identifier
  end

  def call
    reject_legal_identifier
  end

  private

  attr_reader :legal_identifier

  def reject_legal_identifier
    if legal_identifier.reject!
      ServiceResponse.success(payload: {legal_identifier:})
    else
      ServiceResponse.error(payload: {legal_identifier:})
    end
  end
end
