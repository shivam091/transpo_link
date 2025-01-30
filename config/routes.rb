# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  favicon_redirect = redirect do |_params, _request|
    ActionController::Base.helpers.asset_url(TranspoLink::Favicon.main)
  end
  get "favicon.png", to: favicon_redirect
  get "favicon.ico", to: favicon_redirect
end
