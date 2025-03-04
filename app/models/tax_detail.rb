# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetail < ApplicationRecord
  include Sortable, Pageable, Taxable

  enum :entity_type, {
    business: "business",
    individual: "individual"
  }

  enum :business_number_type, {
    ein: "ein",       # Employer Identification Number (USA)
    duns: "duns",     # Dun & Bradstreet Number (USA, International)

    cin: "cin",       # Corporate Identification Number (India)
    roc: "roc",       # Registrar of Companies Number (India)
    acn: "acn",       # Australian Company Number (Australia)
    abn: "abn",       # Australian Business Number (Australia)
    nzbn: "nzbn",     # New Zealand Business Number (New Zealand)

    cnpj: "cnpj",     # National Register of Legal Entities (Brazil)

    bn: "bn",         # Business Number (Canada)

    siret: "siret",   # Business Establishment Identification Number (France)
    siren: "siren",   # Business Identification Number (France)

    crn: "crn",       # Company Registration Number (United Kingdom)
    uen: "uen",       # Unique Entity Number (Singapore)

    rfc: "rfc",       # Federal Taxpayer Registry (Mexico)
    cuit: "cuit",     # Unique Tax Identification Code (Argentina)
    ruc: "ruc",       # Single Taxpayer Registry (Peru, Paraguay, Ecuador, Panama)
    nit: "nit",       # Tax Identification Number (Colombia, Bolivia, Guatemala, El Salvador, Honduras)

    hrb: "hrb",       # Handelsregisternummer (Germany)
    ico: "ico",       # Business Registration Number (Czech Republic, Slovakia)

    npwp: "npwp",     # Taxpayer Identification Number (Indonesia)
    brn: "brn",       # Business Registration Number (Malaysia)
    ssm: "ssm",       # Companies Commission of Malaysia Number (Malaysia)

    ogrn: "ogrn",     # Primary State Registration Number (Russia)

    brn_kr: "brn_kr", # Business Registration Number (South Korea)

    cbr: "cbr",       # Company Business Registration Number (Kenya)
    cr: "cr"          # Commercial Registration Number (Saudi Arabia, UAE, Bahrain, Qatar, Oman)
  }, prefix: true

  normalizes :tax_number, with: -> tax_number { tax_number.strip.upcase }
  normalizes :business_number, with: -> business_number { business_number.strip.upcase }

  validates :user_id,
            presence: true,
            reduce: true
  validates :entity_type,
            presence: true,
            inclusion: {
              in: entity_types.keys
            },
            reduce: true
  validates :tax_number,
            presence: true,
            uniqueness: {
              scope: [:tax_type, :country, :entity_type],
              message: :uniqueness,
              case_sensitive: true
            },
            reduce: true
  validates :business_number_type,
            presence: true,
            inclusion: {
              in: business_number_types.keys
            },
            if: :business?,
            reduce: true
  validates :business_number,
            presence: true,
            uniqueness: {
              scope: [:business_number_type, :country],
              message: :uniqueness,
              case_sensitive: true
            },
            if: :business?,
            reduce: true
  validates :business_number_type, :business_number,
            absence: {message: :absence},
            if: :individual?,
            reduce: true

  belongs_to :user, inverse_of: :tax_details, touch: true

  default_scope -> { order_created_desc }

  class << self
    def accessible(user)
      user.tax_details
    end
  end
end
