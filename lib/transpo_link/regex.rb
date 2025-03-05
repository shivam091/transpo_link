# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module Regex
    extend self

    def strong_password_regex
      @strong_password_regex ||= /\A^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,20}$\z/.freeze
    end

    def email_regex
      @email_regex ||= /^[a-zA-Z0-9_\.\+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/i.freeze
    end

    TAX_IDENTIFIER_PATTERNS = {
      vat: {
        AT: "^(AT)?U[0-9]{8}$",
        BE: "^(BE)?0[0-9]{9}$",
      },
    }.freeze

    BUSINESS_IDENTIFIER_PATTERNS = {
      ein: {
        US: /^\d{2}-\d{7}$/
      }
    }.freeze
  end
end
