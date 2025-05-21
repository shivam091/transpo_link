# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumShippingMethods < ActiveRecord::Migration[8.0]
  def change
    create_enum :shipping_methods, %i[
      AIR SEA ROAD RAIL COURIER POSTAL MULTIMODAL DRONE BIKE HAND_CARRY IN_PERSON
    ]
  end
end
