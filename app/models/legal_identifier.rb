# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifier < ApplicationRecord
  include AASM, Sortable, Pageable, Taxable, NullifyIfBlank, Sanitizable

  LISTING_ATTRIBUTES = %i[
    country entity_type tax_identifier_type tax_identifier
    business_identifier_type business_identifier
  ].freeze

  enum :entity_type, {
    business: "business",
    individual: "individual"
  }

  enum :status, {
    unapproved: "unapproved",
    approved: "approved",
    rejected: "rejected"
  }

  enum :business_identifier_type, {
    ein: "ein",
    duns: "duns",
    cin: "cin",
    llpin: "llpin",
    roc: "roc",
    acn: "acn",
    abn: "abn",
    nzbn: "nzbn",
    cnpj: "cnpj",
    bn: "bn",
    cif: "cif",
    siret: "siret",
    siren: "siren",
    crn: "crn",
    uen: "uen",
    rfc: "rfc",
    cuit: "cuit",
    ruc: "ruc",
    nit: "nit",
    hrb: "hrb",
    ico: "ico",
    npwp: "npwp",
    brn: "brn",
    ssm: "ssm",
    ogrn: "ogrn",
    brn_kr: "brn_kr",
    cr: "cr",
    vkn: "vkn",
    cip: "cip",
    brn_bd: "brn_bd",
    rtn: "rtn",
    uscc: "uscc"
  }, prefix: true

  attribute :status, :enum, default: statuses[:unapproved]

  normalizes :business_identifier, with: ->(business_identifier) { business_identifier.strip.upcase }

  nullify_if_blank :business_identifier, :business_identifier_type

  sanitize_attributes :tax_identifier, :business_identifier

  BUSINESS_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS = {
    ein:      %w[US],
    duns:     %w[US CA GB AU DE FR IT ES NL BR MX ZA IN JP CN KR SG HK AE SA AR CL RU NZ BE DK IE CH],
    cin:      %w[IN],
    llpin:    %w[IN],
    roc:      %w[IN PK],
    acn:      %w[AU],
    abn:      %w[AU],
    nzbn:     %w[NZ],
    cnpj:     %w[BR],
    bn:       %w[CA],
    cif:      %w[ES],
    siret:    %w[FR],
    siren:    %w[FR],
    crn:      %w[GB IE],
    uen:      %w[SG],
    rfc:      %w[MX],
    cuit:     %w[AR],
    ruc:      %w[PE PY EC PA],
    nit:      %w[CO BO GT SV],
    hrb:      %w[DE],
    ico:      %w[CZ SK],
    npwp:     %w[ID],
    brn:      %w[MY],
    ssm:      %w[MY],
    ogrn:     %w[RU],
    brn_kr:   %w[KR],
    cr:       %w[SA AE BH QA OM],
    vkn:      %w[TR],
    cip:      %w[ZA],
    brn_bd:   %w[BD],
    rtn:      %w[HN],
    uscc:     %w[CN]
  }

  aasm column: :status, enum: true, requires_lock: true do
    state :unapproved, initial: true
    state :approved, :rejected

    event :approve do
      transitions from: :unapproved, to: :approved
    end

    event :reject do
      transitions from: :unapproved, to: :rejected
    end
  end

  validates :user_id,
            presence: true,
            reduce: true
  validates :entity_type,
            presence: true,
            inclusion: {in: entity_types.values, message: :inclusion},
            reduce: true
  validates :tax_identifier,
            presence: true,
            uniqueness: {
              scope: [:tax_identifier_type, :country, :entity_type],
              message: :uniqueness,
              case_sensitive: true
            },
            tax_identifier: true,
            reduce: true
  validates :business_identifier_type, :business_identifier,
            absence: {message: :absence},
            if: :individual?,
            reduce: true
  validates :business_identifier_type,
            presence: true,
            inclusion: {in: business_identifier_types.values, message: :inclusion},
            if: :business?,
            reduce: true
  validates :business_identifier,
            presence: true,
            uniqueness: {
              scope: [:business_identifier_type, :country],
              message: :uniqueness,
              case_sensitive: true
            },
            business_identifier: true,
            if: :business?,
            reduce: true
  validates :status,
            presence: true,
            inclusion: {in: statuses.values, message: :inclusion},
            reduce: true

  validate :business_identifier_type_country_combination

  belongs_to :user, inverse_of: :legal_identifiers, touch: true

  default_scope -> { order_created_desc }

  class << self
    def accessible(user)
      user.legal_identifiers
    end
  end

  private

  def business_identifier_type_country_combination
    return unless country.present? && business_identifier_type.present?

    unless BUSINESS_IDENTIFIER_TYPE_COUNTRY_COMBINATIONS[business_identifier_type.to_sym].include?(country)
      errors.add(:business_identifier_type, :invalid)
    end
  end
end
