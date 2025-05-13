# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateFunctionCheckInventoryBatchStockQuantities < ActiveRecord::Migration[8.0]
  def change
    reversible do |migrate|
      migrate.up do
        execute <<~SQL
          CREATE OR REPLACE FUNCTION
            check_inventory_batch_stock_quantities()
          RETURNS trigger AS $$
          DECLARE
            batch_qty numeric;
            used_qty numeric;
          BEGIN
            SELECT
              quantity
            INTO
              batch_qty
            FROM
              inventory_batches
            WHERE
              id = NEW.inventory_batch_id;

            IF NEW.restocked_quantity > batch_qty THEN
              RAISE EXCEPTION 'Restocked quantity (%.2f) exceeds batch quantity (%.2f)', NEW.restocked_quantity, batch_qty;
            END IF;

            used_qty := COALESCE(NEW.ordered_quantity, 0)
                        + COALESCE(NEW.reserved_quantity, 0)
                        + COALESCE(NEW.damaged_quantity, 0)
                        + COALESCE(NEW.returned_quantity, 0);

            IF used_qty > batch_qty THEN
              RAISE EXCEPTION 'Total used quantity (%.2f) exceeds batch quantity (%.2f)', used_qty, batch_qty;
            END IF;

            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;
        SQL
      end

      migrate.down do
        execute <<~SQL
          DROP FUNCTION IF EXISTS
            check_inventory_batch_stock_quantities();
        SQL
      end
    end
  end
end
