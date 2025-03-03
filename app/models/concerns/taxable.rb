# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to provide shared functionality for managing tax-related attributes.
module Taxable
  extend ActiveSupport::Concern

  included do
    enum :tax_type, {
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
      eori: "eori",                         # Economic Operators Registration and Identification Number
      nif: "nif",                           # Tax Identification Number
      cif: "cif",                           # Tax Identification Code
      siret: "siret",                       # Business Identification System
      siren: "siren",                       # Establishment Identification System

      # United Kingdom
      utr: "utr",                           # Unique Taxpayer Reference

      # Canada
      bn: "bn",                             # Business Number
      qst: "qst",                           # Quebec Sales Tax

      # Australia & New Zealand
      abn: "abn",                           # Australian Business Number
      acn: "acn",                           # Australian Company Number
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

      # Hong Kong & Malaysia
      brn: "brn",                           # Business Registration Number

      # Japan
      corporate_number: "corporate_number", # Corporate Number
      my_number: "my_number",               # Individual Tax Number

      # Russia
      inn: "inn",                           # Taxpayer Identification Number
      kpp: "kpp",                           # Tax Registration Reason Code
      ogrn: "ogrn",                         # Principal State Registration Number
      ogrnip: "ogrnip",                     # Individual Entrepreneur Registration Number

      # South Korea
      brn_kr: "brn_kr",                     # Business Registration Number

      # China
      uscc: "uscc",                         # Unified Social Credit Code

      # Vietnam
      mst: "mst",                           # Tax Identification Number

      # Philippines
      tin_ph: "tin_ph",                     # Taxpayer Identification Number

      # Thailand
      tin_th: "tin_th",                     # Taxpayer Identification Number

      # Singapore
      uen: "uen",                           # Unique Entity Number
    }

    validates :tax_type,
              presence: true,
              inclusion: {in: tax_types.values, message: :inclusion},
              reduce: true
    validates :country,
              presence: true,
              if: :requires_country?,
              reduce: true
    validate :tax_type_country_combination
  end

  class_methods do
    INTERNATIONAL_TAX_TYPES = %w[vat gst tin].freeze

    REGIONAL_TAX_TYPES = %w[vatin eori].freeze

    NATIONAL_TAX_TYPES = %w[
      ein ssn itin pan tan gstin nif cif siret siren utr bn qst abn acn tfn ird rfc
      cuit cuil cnpj cpf npwp trn kra_pin corporate_number my_number inn kpp ogrn
      ogrnip brn_kr uscc mst tin_ph tin_th uen
    ].freeze

    COUNTRY_REQUIRING_TAX_TYPES = INTERNATIONAL_TAX_TYPES + REGIONAL_TAX_TYPES + %w[ruc nit brn].freeze

    EU_COUNTRIES_ISO2 = %w[
      AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE
    ].freeze

    VALID_TAX_TYPE_COUNTRY_COMBINATIONS = {
      vat:              EU_COUNTRIES_ISO2 + %w[GB CH NO TR RU BR ZA AE SA EG NG],
      gst:              %w[AU NZ CA IN SG MY],
      tin:              %w[US IN MX PH VN RU CN KE],
      ein:              %w[US],
      ssn:              %w[US],
      itin:             %w[US],
      pan:              %w[IN],
      tan:              %w[IN],
      gstin:            %w[IN],
      vatin:            EU_COUNTRIES_ISO2,
      eori:             EU_COUNTRIES_ISO2 + %w[GB],
      nif:              %w[ES],
      cif:              %w[ES],
      siret:            %w[FR],
      siren:            %w[FR],
      utr:              %w[GB],
      bn:               %w[CA],
      qst:              %w[CA],
      abn:              %w[AU],
      acn:              %w[AU],
      tfn:              %w[AU],
      ird:              %w[NZ],
      rfc:              %w[MX],
      cuit:             %w[AR],
      cuil:             %w[AR],
      ruc:              %w[PE PY EC PA],
      nit:              %w[CO BO SV GT],
      cnpj:             %w[BR],
      cpf:              %w[BR],
      npwp:             %w[ID],
      trn:              %w[AE],
      kra_pin:          %w[KE],
      brn:              %w[MY HK],
      corporate_number: %w[JP],
      my_number:        %w[JP],
      inn:              %w[RU],
      kpp:              %w[RU],
      ogrn:             %w[RU],
      ogrnip:           %w[RU],
      brn_kr:           %w[KR],
      uscc:             %w[CN],
      mst:              %w[VN],
      tin_ph:           %w[PH],
      tin_th:           %w[TH],
      uen:              %w[SG]
    }
  end

  private

  def requires_country?
    tax_type.in?(COUNTRY_REQUIRING_TAX_TYPES)
  end

  def tax_type_country_combination
    return unless country.present? && tax_type.present?

    unless VALID_TAX_TYPE_COUNTRY_COMBINATIONS[tax_type.to_sym].include?(country)
      errors.add(:tax_type, :invalid)
    end
  end
end
