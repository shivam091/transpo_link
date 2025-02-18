# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  sequence :phone_number,
           aliases: %i[mobile_number fax_number registration_number contact_number] do |n|
    n.to_s.rjust(10, "0")
  end

  sequence :email, aliases: %i[email_address] do |n|
    "email#{n}@transpo-link.com"
  end
end
