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
        AT: /^(AT)?U[1-9][0-9]{7}$/,
        BE: /^(BE)?0(?!0{9}$)[0-9]{9}$/,
      },
      ein: {
        US: /^(?!00)(?!9)[0-9]{2}-[0-9]{7}$/
      },
      ssn: {
        US: /^(?!666|000|9[0-9]{2})(?:[0-6][0-9]{2}|7[5-6][0-9]|7[0-4][0-9]|[8][0-9]{2}|899)-(?!00)[0-9]{2}-(?!0000)[0-9]{4}$/
      },
      itin: {
        US: /^9[0-9]{2}-(5[0-9]|6[0-5]|7[0-9]|8[0-2]|88|9[0-2]|9[4-9])-[0-9]{4}$/
      },
      pan: {
        IN: /^[A-Z]{3}(P|F|C|H|A|T|L|B|J|G)[A-Z][0-9]{4}[A-Z]{1}$/
      },
      gstin: {
        IN: /^(0[1-9]|1[0-9]|2[0-9]|3[0-8]|97|99)[A-Z]{3}(P|F|C|H|A|T|L|B|J|G)[A-Z][0-9]{4}[A-Z]{1}[0-9]{1}[Z]{1}[0-9A-Z]{1}$/
      },
      tan: {
        IN: /^[A-Z]{4}[0-9]{5}[A-Z]$/
      },
    }.freeze

    BUSINESS_IDENTIFIER_PATTERNS = {
      ein: {
        US: /^\d{2}-\d{7}$/
      }
    }.freeze
  end
end
