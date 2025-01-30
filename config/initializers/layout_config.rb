# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

TranspoLink::Application.configure do
  config.to_prepare do
    ApplicationController.layout             "application"
  end
end
