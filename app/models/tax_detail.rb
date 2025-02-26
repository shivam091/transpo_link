# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetail < ApplicationRecord
  enum :tax_type, {
    # Global
    vat: "vat",                    # Value Added Tax
    gst: "gst",                    # Goods and Services Tax
    tin: "tin",                    # Taxpayer Identification Number

    # United States
    ein: "ein",                    # Employer Identification Number
    ssn: "ssn",                    # Social Security Number
    itin: "itin",                  # Individual Taxpayer Identification Number

    # India
    pan: "pan",                    # Permanent Account Number
    tan: "tan",                    # Tax Deduction and Collection Account Number
    gstin: "gstin",                # GST Identification Number

    # European Union (EU)
    vatin: "vatin",                # VAT Identification Number
    eori: "eori",                  # Economic Operators Registration and Identification Number
    nif: "nif",                    # Número de Identificación Fiscal (Spain)
    cif: "cif",                    # Código de Identificación Fiscal (Spain)
    siret: "siret",                # Système d’Identification du Répertoire des ENtreprises (France)
    siren: "siren",                # Système d'Identification du Répertoire des Établissements (France)

    # United Kingdom
    utr: "utr",                    # Unique Taxpayer Reference
    pcn: "pcn",                    # Personal Company Number

    # Canada
    bn: "bn",                      # Business Number
    qst: "qst",                    # Quebec Sales Tax

    # Australia & New Zealand
    abn: "abn",                    # Australian Business Number
    acn: "acn",                    # Australian Company Number
    tfn: "tfn",                    # Tax File Number
    ird: "ird",                    # Inland Revenue Department Number (New Zealand)

    # Latin America
    rfc: "rfc",                    # Registro Federal de Contribuyentes (Mexico)
    cuit: "cuit",                  # Clave Única de Identificación Tributaria (Argentina)
    cuil: "cuil",                  # Código Único de Identificación Laboral (Argentina)
    ruc: "ruc",                    # Registro Único de Contribuyentes (Peru, Paraguay, Ecuador, Panama)
    nit: "nit",                    # Número de Identificación Tributaria (Colombia, Bolivia, El Salvador, Guatemala)

    # Brazil
    cnpj: "cnpj",                  # Cadastro Nacional da Pessoa Jurídica (Brazil)
    cpf: "cpf",                    # Cadastro de Pessoas Físicas (Brazil)

    # Indonesia
    npwp: "npwp",                  # Nomor Pokok Wajib Pajak (Indonesia)

    # Middle East & Africa
    trn: "trn",                    # Tax Registration Number (UAE)
    kra_pin: "kra_pin",            # Kenya Revenue Authority PIN

    # Hong Kong & Malaysia
    brn: "brn",                    # Business Registration Number

    # Japan
    pic: "pic",                    # Payee Identification Code

    # Russia & CIS Countries
    inn: "inn",                    # Taxpayer Identification Number (Russia)
    kpp: "kpp",                    # Tax Registration Reason Code (Russia)
    ogrn: "ogrn",                  # Principal State Registration Number (Russia)
    ogrnip: "ogrnip",              # Individual Entrepreneur Registration Number (Russia)

    # South Korea
    brn_kr: "brn_kr",              # Business Registration Number

    # China
    uscc: "uscc",                  # Unified Social Credit Code

    # Vietnam
    mst: "mst",                    # Tax Identification Number

    # Philippines
    tin_ph: "tin_ph",              # Taxpayer Identification Number (Philippines)

    # Thailand
    tin_th: "tin_th",              # Taxpayer Identification Number (Thailand)

    # Singapore
    uen: "uen",                    # Unique Entity Number
  }

  # Define tax types that require a country
  COUNTRY_SPECIFIC_TAX_TYPES = %w[
    ein ssn itin pan tan gstin vatin eori nif cif siret siren utr pcn bn qst abn
    acn tfn ird rfc cuit cuil ruc nit cnpj cpf npwp trn kra_pin brn pic inn kpp
    ogrn ogrnip brn_kr uscc mst tin_ph tin_th uen
  ].freeze

  belongs_to :user, inverse_of: :tax_details, touch: true
end
