# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumTaxTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :tax_types, %i[
                                vat
                                gst
                                ein
                                ssn
                                itin
                                tin
                                cif
                                nif
                                rfc
                                abn
                                bn
                                pan
                                gstin
                                cnpj
                                cpf
                                siret
                                siren
                                tan
                                trn
                                brn
                                ird
                                ubi
                                cuit
                                cuil
                                ruc
                                nit
                                npwp
                                kra_pin
                                gst_certificate
                                vatin
                                qst
                                pcn
                                business_id
                                tax_number
                              ]
  end
end
