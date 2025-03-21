class CreateEnumTrackingMethods < ActiveRecord::Migration[8.0]
  def change
    create_enum :tracking_methods, %i[fifo lifo average_cost]
  end
end
