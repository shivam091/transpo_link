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
  end
end
