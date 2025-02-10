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

  devise_for :users,
             path_names: {
               sign_in: "sign-in", sign_out: "sign-out", sign_up: "sign-up"
             },
             controllers: {
               sessions: "users/sessions",
               confirmations: "users/confirmations",
               passwords: "users/passwords",
               unlocks: "users/unlocks",
               registrations: "users/registrations"
             }

  resource :profile, only: [:show, :edit, :update]
  resource :preference, only: [:show, :edit, :update]

  root to: "dashboards#show"
end
