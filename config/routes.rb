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
      get :active, action: :index, defaults: {status: "active"}
      get :inactive, action: :index, defaults: {status: "inactive"}
    end
  end

  concern :reviewable do
    resources :feedbacks, only: [:new, :create]
  end

  concern :notifiable do
    collection do
      get :read, action: :index, defaults: {status: "read"}
      get :unread, action: :index, defaults: {status: "unread"}
    end

    member do
      match :mark_as_read, path: "mark-as-read", via: [:put, :patch]
    end
  end

  resource :profile, only: [:show, :edit, :update]

  resource :preference, only: [:show, :edit, :update]

  resource :color_scheme, path: "color-scheme", only: :update

  resource :locale, only: [:edit, :update]

  resources :states, only: :index

  resources :roles, except: [:new, :create, :destroy]

  resources :users, only: [:index, :show], concerns: :toggleable do
    collection do
      get :suspended, action: :index, defaults: {status: "suspended"}
    end
  end

  resources :request_logs, path: "request-logs", only: [:index, :show]

  resources :warehouses, concerns: :toggleable

  resources :legal_identifiers, path: "legal-identifiers", except: :show do
    member do
      patch :approve
      patch :reject
    end

    collection do
      get :approved, action: :index, defaults: {status: "approved"}
      get :unapproved, action: :index, defaults: {status: "unapproved"}
      get :rejected, action: :index, defaults: {status: "rejected"}
    end
  end

  resources :tax_rates, path: "tax-rates", except: :show do
    collection do
      get :active, action: :index, defaults: {status: "active"}
      get :future, action: :index, defaults: {status: "future"}
      get :expired, action: :index, defaults: {status: "expired"}
    end
  end

  resources :product_categories, path: "product-categories", except: :show, concerns: :toggleable

  resources :products, concerns: [:reviewable, :toggleable] do
    resources :product_prices, path: "product-prices", except: :index, module: :products
  end

  resources :feedbacks, only: [:index, :show], concerns: :notifiable

  resources :inventories, except: :destroy do
    resources :inventory_batches, path: "inventory-batches", only: :index, module: :inventories, shallow: true do
      resources :inventory_restocks, path: "restocks", only: [:new, :create]
    end
  end

  resources :purchase_orders, path: "purchase-orders" do
    member do
      patch :cancel
      patch :submit
      patch :approve
      patch :reject
    end

    resource :delivery, only: [:new, :create], module: :purchase_orders

    resources :purchase_order_items, path: "purchase-order-items", shallow: true do
      member do
        patch :cancel
      end

      resources :deliveries, only: [:new, :create], module: :purchase_order_items

      resources :inventory_batches, path: "inventory-batches", only: [:new, :create], module: :purchase_order_items
    end
  end

  resources :units, only: :index

  resources :unit_conversions, path: "unit-conversions", only: :index

  root to: "dashboards#show"

  match "*unmatched_route", to: "application#render_not_found", via: :all
end
