# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.after_initialize do
    if defined?(Bullet)
      Bullet.enable               = true
      Bullet.alert                = Rails.env.development?
      Bullet.bullet_logger        = true
      Bullet.console              = true
      Bullet.rails_logger         = true
      Bullet.add_footer           = true
      Bullet.raise                = false
      Bullet.counter_cache_enable = true
    end
  end
end
