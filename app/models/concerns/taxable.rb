# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to provide shared functionalities for managing tax-related attributes.
module Taxable
  extend ActiveSupport::Concern

  included do
    normalizes :tax_identifier, with: -> tax_identifier { tax_identifier.strip.upcase }

    enum :tax_identifier_type, {
      # Global
      vat: "vat",                           # Value Added Tax
      gst: "gst",                           # Goods and Services Tax
      tin: "tin",                           # Taxpayer Identification Number

      # United States
      ein: "ein",                           # Employer Identification Number
      ssn: "ssn",                           # Social Security Number
      itin: "itin",                         # Individual Taxpayer Identification Number

      # India
      pan: "pan",                           # Permanent Account Number
      tan: "tan",                           # Tax Deduction and Collection Account Number
      gstin: "gstin",                       # GST Identification Number

      # European Union (EU)
      vatin: "vatin",                       # VAT Identification Number
      nie: "nie",                           # Foreigner Identification Number
      nif: "nif",                           # Tax Identification Number

      # United Kingdom
      utr: "utr",                           # Unique Taxpayer Reference

      # Canada
      bn: "bn",                             # Business Number
      qst: "qst",                           # Quebec Sales Tax

      # Australia & New Zealand
      abn: "abn",                           # Australian Business Number
      tfn: "tfn",                           # Tax File Number
      ird: "ird",                           # Inland Revenue Department Number

      # Latin America
      rfc: "rfc",                           # Federal Taxpayer Registry
      cuit: "cuit",                         # Unique Tax Identification Code
      cuil: "cuil",                         # Unique Labor Identification Code
      ruc: "ruc",                           # Single Taxpayer Registry
      nit: "nit",                           # Tax Identification Number

      # Brazil
      cnpj: "cnpj",                         # National Register of Legal Entities
      cpf: "cpf",                           # Register of Natural Persons

      # Indonesia
      npwp: "npwp",                         # Taxpayer Identification Number

      # Middle East & Africa
      trn: "trn",                           # Tax Registration Number
      kra_pin: "kra_pin",                   # Kenya Revenue Authority PIN

      # Russia
      inn: "inn",                           # Taxpayer Identification Number

      # South Korea
      brn_kr: "brn_kr",                     # Business Registration Number

      # Vietnam
      mst: "mst",                           # Tax Identification Number

      # Philippines
      tin_ph: "tin_ph",                     # Taxpayer Identification Number

      # Thailand
      tin_th: "tin_th",                     # Taxpayer Identification Number

      # Singapore
      uen: "uen",                           # Unique Entity Number

      # Colombia
      rut: "rut"                            # Single Tax Registry
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
      vat:     EU_COUNTRIES + %w[GB CH NO TR BR ZA AE SA EG NG],
      gst:     %w[AU NZ CA IN SG MY],
      tin:     %w[US IN PH VN CN KE],
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
      brn_kr:  %w[KR],
      mst:     %w[VN],
      tin_ph:  %w[PH],
      tin_th:  %w[TH],
      uen:     %w[SG],
      rut:     %w[CO]
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
