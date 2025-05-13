# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddRestockedAndUsedQuantityTriggersToInventoryBatchStocks < ActiveRecord::Migration[8.0]
  def change
    reversible do |migrate|
      migrate.up do
        execute <<~SQL
          CREATE TRIGGER
            validate_inventory_batch_quantities
          BEFORE
            INSERT OR UPDATE
          ON
            inventory_batch_stocks
          FOR EACH ROW
          EXECUTE FUNCTION
            check_inventory_batch_stock_quantities();
        SQL
      end

      migrate.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS
            validate_inventory_batch_quantities
          ON
            inventory_batch_stocks;
        SQL
      end
    end
  end
end
