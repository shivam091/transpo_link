# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiers::DestroyService < ApplicationService
  def initialize(legal_identifier)
    @legal_identifier = legal_identifier
  end

  def call
    destroy_legal_identifier
  end

  private

  attr_reader :legal_identifier

  def destroy_legal_identifier
    if legal_identifier.destroy
      ServiceResponse.success(payload: {legal_identifier:})
    else
      ServiceResponse.error(payload: {legal_identifier:})
    end
  end
end
