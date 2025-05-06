# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UniqueProductInCollectionValidator < ActiveModel::Validator
  def initialize(options)
    super
    @parent = options.fetch(:parent)
    @collection = options.fetch(:collection)
    @error_message = options.fetch(:message, :uniqueness)
  end

  def validate(record)
    return if record.marked_for_destruction?
    return unless (parent = record.public_send(@parent))
    return unless (collection = parent.public_send(@collection)).loaded?

    first_match = collection.find do |item|
      !item.marked_for_destruction? && item.product_id == record.product_id
    end

    if first_match && first_match != record
      record.errors.add(:product_id, @error_message)
    end
  end
end
