# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Custom validator for showing single validation error message for each attribute.
#
# Example:
#
#   class Model < ActiveRecord::Base
#     validates :attribute,
#               presence: true,
#               length: {in: 2..10}
#               reduce: true
#   end
#
class ReduceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless (existing_errors = record.errors[attribute]).many?

    record.errors.delete(attribute)
    record.errors.add(attribute, existing_errors.first)
  end
end
