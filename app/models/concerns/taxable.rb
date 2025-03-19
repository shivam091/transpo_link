# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to provide shared functionalities for managing tax-related attributes.
module Taxable
  extend ActiveSupport::Concern

  included do
    normalizes :tax_identifier, with: -> tax_identifier { tax_identifier.strip.upcase }

    enum :tax_identifier_type, {
      vat: "vat",
      gst: "gst",
      tin: "tin",
      ein: "ein",
      ssn: "ssn",
      itin: "itin",
      pan: "pan",
      tan: "tan",
      gstin: "gstin",
      vatin: "vatin",
      nie: "nie",
      nif: "nif",
      utr: "utr",
      bn: "bn",
      qst: "qst",
      abn: "abn",
      tfn: "tfn",
      ird: "ird",
      rfc: "rfc",
      cuit: "cuit",
      cuil: "cuil",
      ruc: "ruc",
      nit: "nit",
      cnpj: "cnpj",
      cpf: "cpf",
      npwp: "npwp",
      trn: "trn",
      kra_pin: "kra_pin",
      inn: "inn",
      kpp: "kpp",
      brn_kr: "brn_kr",
      mst: "mst",
      uen: "uen",
      rut: "rut",
      rtn: "rtn"
    }

    validates :tax_identifier_type,
              presence: true,
              inclusion: {
                in: tax_identifier_types.values,
                message: :inclusion
              },
              reduce: true
    validates :country,
              presence: true,
              reduce: true
    validate :tax_identifier_type_country_combination
  end

  class_methods do
    EU_COUNTRIES = %w[
      AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI
      ES SE
    ].freeze

    TAX_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS = {
      vat:     EU_COUNTRIES + %w[GB CH NO RS ZA SA EG NG],
      gst:     %w[AU NZ CA IN SG MY],
      tin:     %w[US IN PH TH VN CN KE],
      ein:     %w[US],
      ssn:     %w[US],
      itin:    %w[US],
      pan:     %w[IN],
      tan:     %w[IN],
      gstin:   %w[IN],
      vatin:   EU_COUNTRIES,
      nie:     %w[ES],
      nif:     %w[ES],
      utr:     %w[GB],
      bn:      %w[CA],
      qst:     %w[CA],
      abn:     %w[AU],
      tfn:     %w[AU],
      ird:     %w[NZ],
      rfc:     %w[MX CO AR PE PY EC PA BO SV GT],
      cuit:    %w[AR],
      cuil:    %w[AR],
      ruc:     %w[PE PY EC PA],
      nit:     %w[CO BO SV GT],
      cnpj:    %w[BR],
      cpf:     %w[BR],
      npwp:    %w[ID],
      trn:     %w[AE],
      kra_pin: %w[KE],
      inn:     %w[RU],
      kpp:     %w[RU],
      brn_kr:  %w[KR],
      mst:     %w[VN],
      uen:     %w[SG],
      rut:     %w[CO],
      rtn:     %w[HN]
    }
  end

  private

  def tax_identifier_type_country_combination
    return unless country.present? && tax_identifier_type.present?

    unless TAX_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS[tax_identifier_type.to_sym].include?(country)
      errors.add(:tax_identifier_type, :invalid)
    end
  end
end
