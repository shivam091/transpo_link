# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumIncotermCodes < ActiveRecord::Migration[8.0]
  def change
    create_enum :incoterm_codes, %i[EXW FCA FOB CFR CIF DAP DPU DDP]
  end
end
