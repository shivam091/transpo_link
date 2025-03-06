# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Custom validator for checking whether attribute's value has valid password format.
# It requires lowercase, uppercase letters, atleast one number, and atleast one
# special character
#
# Example:
#
#   class Model < ActiveRecord::Base
#     validates :attribute, password: true
#   end
#
class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ TranspoLink::Regex::STRONG_PASSWORD_REGEX
      error_message = options[:message] || :invalid

      record.errors.add(attribute, error_message)
    end
  end
end
