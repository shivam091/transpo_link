# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumTaxTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :tax_types, %i[
      vat gst tin ein ssn itin pan tan gstin vatin eori nif cif siret siren utr
      bn qst abn acn tfn ird rfc cuit cuil ruc nit cnpj cpf npwp trn kra_pin brn
      corporate_number my_number inn kpp ogrn ogrnip brn_kr uscc mst tin_ph
      tin_th uen
    ]
  end
end
