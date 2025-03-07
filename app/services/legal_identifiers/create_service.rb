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
      ServiceResponse.success(message: t("legal_identifiers.create.notice"), payload: {legal_identifier: legal_identifier})
    else
      ServiceResponse.error(message: t("legal_identifiers.create.alert"), payload: {legal_identifier: legal_identifier})
    end
  end
end
