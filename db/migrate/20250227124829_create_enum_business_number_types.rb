# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumBusinessNumberTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :business_number_types, %i[
      ein duns cin roc acn abn nzbn cnpj bn siret siren crn uen rfc cuit ruc nit
      hrb ico npwp brn ssm ogrn brn_kr cbr cr
    ]
  end
end
