# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiers::CreateService < ApplicationService
  def initialize(user, legal_identifier_attributes)
    @user, @legal_identifier_attributes = user, legal_identifier_attributes
  end

  def call
    create_legal_identifier
  end

  private

  attr_reader :user, :legal_identifier_attributes

  def create_legal_identifier
    legal_identifier = user.legal_identifiers.build(legal_identifier_attributes)

    if legal_identifier.save
      ServiceResponse.success(payload: {legal_identifier:})
    else
      ServiceResponse.error(payload: {legal_identifier:})
    end
  end
end
