# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumLegalIdentifierStatuses < ActiveRecord::Migration[8.0]
  def change
    create_enum :legal_identifier_statuses, %i[unapproved approved rejected]
  end
end
