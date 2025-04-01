# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumPurchaseOrderItemStatuses < ActiveRecord::Migration[8.0]
  def change
    create_enum :purchase_order_item_statuses,
                %i[
                  pending
                  delivered
                  cancelled
                ]
  end
end
