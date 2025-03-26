# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module that sanitizes attributes prior to validation to remove unwanted
# characters, ensuring clean and safe data storage.
#
# By default, all HTML is stripped from attributes unless explicitly allowed.
#
# Model usage:
#
# ```
# class User < ApplicationRecord
#   include Sanitizable
#
#   sanitize_attributes :name
#   sanitize_attributes :bio, allow_html: true
# end
#```
#
# Test usage
#
# ```
# RSpec.describe User do
#   it { is_expected.to sanitize_attribute(:name) }
#   it { is_expected.to sanitize_attribute(:bio).allow_html }
# end
# ```
module Sanitizable
  extend ActiveSupport::Concern

  included do
    class_attribute :sanitizable_attributes, instance_writer: false, default: []

    before_validation :sanitize_attributes
  end

  class_methods do
    def sanitize_attributes(*attributes, allow_html: false)
      attributes.each do |attribute|
        self.sanitizable_attributes << {attribute:, allow_html:}
      end
    end
  end

  private

  def sanitize_attributes
    self.class.sanitizable_attributes.each do |config|
      attribute = config[:attribute]
      allow_html = config[:allow_html]

      value = self[attribute]
      self[attribute] = sanitize(value, allow_html) if value.present?
    end
  end

  def sanitize(value, allow_html)
    fragment = Loofah.fragment(value.to_s)
    sanitized_value = if allow_html
      fragment.scrub!(:prune).to_s.strip
    else
      fragment.scrub!(:strip).to_text.strip
    end

    sanitized_value.gsub(/\p{C}/, "")
  end
end
