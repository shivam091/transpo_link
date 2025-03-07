# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Custom validator for checking whether attribute's value is valid email.
#
# Example:
#
#   class Model < ActiveRecord::Base
#     validates :attribute, email: true
#   end
#
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ TranspoLink::Regex::EMAIL_REGEX
      error_message = options[:message] || :invalid

      record.errors.add(attribute, error_message)
    end
  end
end
