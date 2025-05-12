# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumInventoryBatchStockStatuses < ActiveRecord::Migration[8.0]
  def change
    create_enum :inventory_batch_stock_statuses,
                %i[
                  available
                  reserved
                  partially_used
                  exhausted
                  locked
                  damaged
                  closed
                ]
  end
end
