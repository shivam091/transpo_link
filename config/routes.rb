# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
end
