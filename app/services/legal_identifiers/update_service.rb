# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiers::UpdateService < ApplicationService
  def initialize(legal_identifier, legal_identifier_attributes)
    @legal_identifier, @legal_identifier_attributes = legal_identifier, legal_identifier_attributes
  end

  def call
    update_legal_identifier
  end

  private

  attr_reader :legal_identifier, :legal_identifier_attributes

  def update_legal_identifier
    if legal_identifier.update(legal_identifier_attributes)
      ServiceResponse.success(message: t("legal_identifiers.update.notice"), payload: {legal_identifier: legal_identifier})
    else
      ServiceResponse.error(message: t("legal_identifiers.update.alert"), payload: {legal_identifier: legal_identifier})
    end
  end
end
