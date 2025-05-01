# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    enumerations: {
      user_preference: {
        preferred_color_schemes: {
          auto: "System",
          light: "Light",
          dark: "Dark"
        },
        first_day_of_weeks: {
          sunday: "Sunday",
          monday: "Monday",
          saturday: "Saturday"
        },
      },
      legal_identifier: {
        tax_identifier_types: {
          vat: "VAT – Value Added Tax",
          gst: "GST – Goods and Services Tax",
          tin: "TIN – Taxpayer Identification Number",
          ein: "EIN – Employer Identification Number",
          ssn: "SSN – Social Security Number",
          itin: "ITIN – Individual Taxpayer Identification Number",
          pan: "PAN – Permanent Account Number",
          tan: "TAN – Tax Deduction and Collection Account Number",
          gstin: "GSTIN – GST Identification Number",
          vatin: "VATIN – VAT Identification Number",
          nie: "NIE – Número de Identificación de Extranjero",
          nif: "NIF – Número de Identificación Fiscal",
          utr: "UTR – Unique Taxpayer Reference",
          bn: "BN – Business Number",
          qst: "QST – Taxe de vente du Québec",
          abn: "ABN – Australian Business Number",
          tfn: "TFN – Tax File Number",
          ird: "IRD – Inland Revenue Department Number",
          rfc: "RFC – Registro Federal de Contribuyentes",
          cuit: "CUIT – Clave Única de Identificación Tributaria",
          cuil: "CUIL – Código Único de Identificación Laboral",
          ruc: "RUC – Registro Único de Contribuyentes",
          nit: "NIT – Número de Identificación Tributaria",
          cnpj: "CNPJ – Cadastro Nacional da Pessoa Jurídica",
          cpf: "CPF – Cadastro de Pessoas Físicas",
          npwp: "NPWP – Nomor Pokok Wajib Pajak",
          trn: "TRN – Tax Registration Number",
          kra_pin: "KRA_PIN – Kenya Revenue Authority PIN",
          inn: "INN – Идентификационный номер налогоплательщика",
          kpp: "KPP – Код причины постановки на учет",
          brn_kr: "BRN_KR – 사업자등록번호",
          mst: "MST – Mã số thuế",
          uen: "UEN – Unique Entity Number",
          rut: "RUT – Rol Único Tributario",
          rtn: "RTN – Registro Tributario Nacional",
        },
        entity_types: {
          business: "Business",
          individual: "Individual"
        },
        business_identifier_types: {
          ein: "EIN – Employer Identification Number",
          duns: "DUNS – Data Universal Numbering System (Issued by Dun & Bradstreet (D&B))",
          cin: "CIN – Corporate Identification Number",
          llpin: "LLPIN - Limited Liability Partnership Identification Number",
          roc: "ROC – Registrar of Companies",
          acn: "ACN – Australian Company Number",
          abn: "ABN – Australian Business Number",
          nzbn: "NZBN – New Zealand Business Number",
          cnpj: "CNPJ – Cadastro Nacional da Pessoa Jurídica",
          bn: "BN – Business Number",
          cif: "CIF – Código de Identificación Fiscal",
          siret: "SIRET – Système d’Identification du Répertoire des Établissements",
          siren: "SIREN – Système d’Identification du Répertoire des Entreprises",
          crn: "CRN – Company Registration Number",
          uen: "UEN – Unique Entity Number",
          rfc: "RFC – Registro Federal de Contribuyentes",
          cuit: "CUIT – Clave Única de Identificación Tributaria",
          ruc: "RUC – Registro Único de Contribuyentes",
          nit: "NIT – Número de Identificación Tributaria",
          hrb: "HRB – Handelsregister-Betriebsnummer",
          ico: "ICO – Identifikační číslo osoby",
          npwp: "NPWP – Nomor Pokok Wajib Pajak",
          brn: "BRN – Business Registration Number",
          ssm: "SSM – Nombor Suruhanjaya Syarikat Malaysia",
          ogrn: "OGRN – Основной государственный регистрационный номер",
          brn_kr: "BRN_KR – 사업자등록번호",
          cr: "CR – رقم السجل التجاري",
          vkn: "VKN – Vergi Kimlik Numarası",
          cip: "CIP – Company Identification Number",
          brn_bd: "BRN_BD – ব্যবসায় নিবন্ধন নম্বর",
          rtn: "RTN – Registro Tributario Nacional",
          uscc: "USCC – 统一社会信用代码",
        }
      },
      tax_rate: {
        tax_identifier_types: {
          vat: "VAT – Value Added Tax",
          gst: "GST – Goods and Services Tax",
          tin: "TIN – Taxpayer Identification Number",
          ein: "EIN – Employer Identification Number",
          ssn: "SSN – Social Security Number",
          itin: "ITIN – Individual Taxpayer Identification Number",
          pan: "PAN – Permanent Account Number",
          tan: "TAN – Tax Deduction and Collection Account Number",
          gstin: "GSTIN – GST Identification Number",
          vatin: "VATIN – VAT Identification Number",
          nie: "NIE – Número de Identificación de Extranjero",
          nif: "NIF – Número de Identificación Fiscal",
          utr: "UTR – Unique Taxpayer Reference",
          bn: "BN – Business Number",
          qst: "QST – Taxe de vente du Québec",
          abn: "ABN – Australian Business Number",
          tfn: "TFN – Tax File Number",
          ird: "IRD – Inland Revenue Department Number",
          rfc: "RFC – Registro Federal de Contribuyentes",
          cuit: "CUIT – Clave Única de Identificación Tributaria",
          cuil: "CUIL – Código Único de Identificación Laboral",
          ruc: "RUC – Registro Único de Contribuyentes",
          nit: "NIT – Número de Identificación Tributaria",
          cnpj: "CNPJ – Cadastro Nacional da Pessoa Jurídica",
          cpf: "CPF – Cadastro de Pessoas Físicas",
          npwp: "NPWP – Nomor Pokok Wajib Pajak",
          trn: "TRN – Tax Registration Number",
          kra_pin: "KRA_PIN – Kenya Revenue Authority PIN",
          inn: "INN – Идентификационный номер налогоплательщика",
          kpp: "KPP – Код причины постановки на учет",
          brn_kr: "BRN_KR – 사업자등록번호",
          mst: "MST – Mã số thuế",
          uen: "UEN – Unique Entity Number",
          rut: "RUT – Rol Único Tributario",
          rtn: "RTN – Registro Tributario Nacional",
        },
        business_categories: {
          b2b: "Business to Business (B2B)",
          b2c: "Business to Consumer (B2C)"
        },
        tax_types: {
          exclusive: "Exclusive",
          inclusive: "Inclusive"
        },
      },
      inventory: {
        tracking_methods: {
          fifo: "First-in, first-out",
          lifo: "Last-in, first-out",
          average_cost: "Weighted average costing"
        },
      },
      purchase_order: {
        statuses: {
          draft: "Draft",
          submitted: "Submitted",
          approved: "Approved",
          partially_delivered: "Partially delivered",
          fully_delivered: "Fully delivered",
          cancelled: "Cancelled",
          rejected: "Rejected",
          closed: "Closed",
          on_hold: "On hold",
        },
      },
      purchase_order_item: {
        statuses: {
          pending: "Pending",
          ordered: "Ordered",
          partially_delivered: "Partially delivered",
          delivered: "Delivered",
          cancelled: "Cancelled",
        },
      },
      unit: {
        categories: {
          count: "Count",
          length: "Length",
          weight: "Weight",
          area: "Area",
          volume: "Volume"
        }
      },
      inventory_batch_processing_log: {
        status: {
          pending: "Pending",
          queued: "Queued",
          processing: "Processing",
          succeeded: "Succeeded",
          failed: "Failed"
        },
      },
    }
  }
}
