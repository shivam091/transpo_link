# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Mailer::EmailService < ApplicationService
  def initialize
  end

  def call
    send_email
    notify_user
  end

  private

  def send_email
  end

  def notify_user
  end
end
