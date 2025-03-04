# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetail < ApplicationRecord
  include Sortable, Pageable, Taxable, NullifyIfBlank

  enum :entity_type, {
    business: "business",
    individual: "individual"
  }

  enum :business_number_type, {
    # USA
    ein: "ein",                             # Employer Identification Number
    duns: "duns",                           # Dun & Bradstreet Number

    # India
    cin: "cin",                             # Corporate Identification Number
    roc: "roc",                             # Registrar of Companies Number

    # Australia
    acn: "acn",                             # Australian Company Number
    abn: "abn",                             # Australian Business Number

    # New Zealand
    nzbn: "nzbn",                           # New Zealand Business Number

    # Brazil
    cnpj: "cnpj",                           # National Register of Legal Entities

    # Canada
    bn: "bn",                               # Business Number

    # France
    siret: "siret",                         # Business Establishment Identification Number
    siren: "siren",                         # Business Identification Number

    # United Kingdom
    crn: "crn",                             # Company Registration Number

    # Singapore
    uen: "uen",                             # Unique Entity Number

    # Mexico
    rfc: "rfc",                             # Federal Taxpayer Registry

    # Argentina
    cuit: "cuit",                           # Unique Tax Identification Code

    # Peru, Paraguay, Ecuador, Panama
    ruc: "ruc",                             # Single Taxpayer Registry

    # Colombia, Bolivia, Guatemala, El Salvador, Honduras
    nit: "nit",                             # Tax Identification Number

    # Germany
    hrb: "hrb",                             # Handelsregisternummer

    # Czech Republic, Slovakia
    ico: "ico",                             # Business Registration Number

    # Indonesia
    npwp: "npwp",                           # Taxpayer Identification Number

    # Malaysia
    brn: "brn",                             # Business Registration Number
    ssm: "ssm",                             # Companies Commission of Malaysia Number

    # Russia
    ogrn: "ogrn",                           # Primary State Registration Number

    # South Korea
    brn_kr: "brn_kr",                       # Business Registration Number

    # Kenya
    cbr: "cbr",                             # Company Business Registration Number

    # Saudi Arabia, UAE, Bahrain, Qatar, Oman
    cr: "cr"                                # Commercial Registration Number
  }, prefix: true

  normalizes :tax_number, with: -> tax_number { tax_number.strip.upcase }
  normalizes :business_number, with: -> business_number { business_number.strip.upcase }

  nullify_if_blank :business_number

  VALID_BUSINESS_NUMBER_TYPE_COUNTRY_COMBINATIONS = {
    ein:      %w[US],
    duns:     %w[US INT],
    cin:      %w[IN],
    roc:      %w[IN],
    acn:      %w[AU],
    abn:      %w[AU],
    nzbn:     %w[NZ],
    cnpj:     %w[BR],
    bn:       %w[CA],
    siret:    %w[FR],
    siren:    %w[FR],
    crn:      %w[GB],
    uen:      %w[SG],
    rfc:      %w[MX],
    cuit:     %w[AR],
    ruc:      %w[PE PY EC PA],
    nit:      %w[CO BO GT SV HN],
    hrb:      %w[DE],
    ico:      %w[CZ SK],
    npwp:     %w[ID],
    brn:      %w[MY],
    ssm:      %w[MY],
    ogrn:     %w[RU],
    brn_kr:   %w[KR],
    cbr:      %w[KE],
    cr:       %w[SA AE BH QA OM]
  }

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
  validate :business_number_type_country_combination

  belongs_to :user, inverse_of: :tax_details, touch: true

  default_scope -> { order_created_desc }

  class << self
    def accessible(user)
      user.tax_details
    end
  end

  private

  def business_number_type_country_combination
    return unless country.present? && business_number_type.present?

    unless VALID_BUSINESS_NUMBER_TYPE_COUNTRY_COMBINATIONS[business_number_type.to_sym].include?(country)
      errors.add(:business_number_type, :invalid)
    end
  end
end
