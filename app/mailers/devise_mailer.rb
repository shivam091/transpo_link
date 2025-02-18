# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class DeviseMailer < Devise::Mailer
  def confirmation_instructions(user, token, options = {})
  end

  def reset_password_instructions(user, token, options = {})
  end

  def unlock_instructions(user, token, options = {})
  end

  def email_changed(user, options = {})
  end

  def password_change(user, options = {})
  end
end
