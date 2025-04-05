# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumPurchaseOrderStatuses < ActiveRecord::Migration[8.0]
  def change
    create_enum :purchase_order_statuses,
                %i[
                  draft
                  pending
                  approved
                  cancelled
                  rejected
                  partially_delivered
                  fully_delivered
                ]
  end
end
