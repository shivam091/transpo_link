# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  favicon_redirect = redirect do |_params, _request|
    ActionController::Base.helpers.asset_url(TranspoLink::Favicon.main)
  end
  get "favicon.png", to: favicon_redirect, as: :favicon_png
  get "favicon.ico", to: favicon_redirect, as: :favicon_ico

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

  concern :toggleable do
    collection do
       get :active
       get :inactive
    end
  end

  concern :reviewable do
    resources :feedbacks, only: [:new, :create]
  end

  resource :profile, only: [:show, :edit, :update]
  resource :preference, only: [:show, :edit, :update]
  resource :locale, only: [:edit, :update]

  resources :roles, except: [:new, :create, :destroy]
  resources :users, only: [:index, :show]
  resources :request_logs, path: "request-logs", only: [:index, :show]
  resources :warehouses, concerns: :toggleable
  resources :legal_identifiers, path: "legal-identifiers", except: :show
  resources :tax_rates, path: "tax-rates", except: :show
  resources :product_categories, path: "product-categories", except: :show
  resources :products, concerns: :reviewable do
    collection do
      get "active", action: :index, defaults: {status: "active"}
      get "inactive", action: :index, defaults: {status: "inactive"}
    end
  end
  resources :feedbacks, only: [:index, :show] do
    collection do
      get "read", action: :index, defaults: {status: "read"}
      get "unread", action: :index, defaults: {status: "unread"}
    end
    member do
      match :mark_as_read, path: "mark-as-read", via: [:put, :patch]
    end
  end

  root to: "dashboards#show"
end
