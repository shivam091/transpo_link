# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

#
# Provides both controller-wide and action-specific declarative authorization.
#
# This module allows Rails controllers to define access control at the class level
# for all actions (`requires_authorization`) or for specific actions (`requires_authorization_for`).
#
# It automatically runs a `before_action` callback to enforce permissions and
# also exposes a method `require_authorization` for manual use inside controller actions.
#
# ## Assumptions
# - `current_user` method must be defined and return the current user.
# - `Ability` class must implement `authorize!(module_key, action_key)` to check access.
#
# ## Usage
#
# @example Controller-wide authorization
#   class OrdersController < ApplicationController
#     include ContextualAuthorization
#
#     requires_authorization :orders, :manage
#   end
#
# @example Action-specific authorization
#   class InventoriesController < ApplicationController
#     include ContextualAuthorization
#
#     requires_authorization_for :create, :inventories, :restock
#     requires_authorization_for :destroy, :inventories, :delete
#     requires_authorization_for [:new, :create], :inventories, :create
#   end
#
# @example Manual authorization inside action
#   class ItemsController < ApplicationController
#     include ContextualAuthorization
#
#     def show
#       require_authorization :items, :view
#     end
#   end
#
module ContextualAuthorization
  extend ActiveSupport::Concern

  included do
    # @!attribute [r] authorization_context
    #   @return [Array<([Symbol, String], [Symbol, String]), nil>] The module and action keys applied controller-wide
    class_attribute :authorization_context, instance_accessor: false

    # @!attribute [r] action_authorization_map
    #   @return [Hash<Symbol, Array<[Symbol, String], [Symbol, String]>>] A map of actions to their module/action keys
    class_attribute :action_authorization_map, default: {}, instance_accessor: false

    before_action :authorize_combined_context!
  end

  class_methods do
    # Sets a controller-wide authorization requirement.
    # This applies to all actions unless overridden by `requires_authorization_for`.
    #
    # @param module_key [Symbol, String] The module identifier (e.g., "orders")
    # @param action_key [Symbol, String] The action identifier (e.g., "manage", "view")
    # @return [void]
    #
    # @example
    #   requires_authorization :orders, :manage
    def requires_authorization(module_key, action_key)
      self.authorization_context = [module_key.to_s, action_key.to_s]
    end

    # Sets a specific authorization rule for a particular controller action.
    #
    # @param action_name [Symbol, String] The name of the controller action (e.g., :create)
    # @param module_key [Symbol, String] The module identifier
    # @param action_key [Symbol, String] The action identifier
    # @return [void]
    #
    # @example
    #   requires_authorization_for :create, :orders, :create
    #   requires_authorization_for [:new, :create], :orders, :create
    def requires_authorization_for(action_names, module_key, action_key)
      action_names = Array(action_names).map(&:to_sym)
      updates = action_names.index_with { [module_key.to_s, action_key.to_s] }
      self.action_authorization_map = action_authorization_map.merge(updates)
    end
  end

  # Manually enforces authorization within any controller action.
  #
  # This method is useful when dynamic or context-sensitive permissions are needed.
  #
  # @param module_key [Symbol, String] The module to authorize against
  # @param action_key [Symbol, String] The action to authorize
  # @raise [AccessDeniedError] If the user is not authorized
  # @return [void]
  #
  # @example
  #   require_authorization :products, :edit
  def require_authorization(module_key, action_key)
    current_ability.authorize!(module_key.to_s, action_key.to_s)
  end

  private

  # Lazily initializes and returns the current user's ability object.
  #
  # @return [Ability] The ability instance scoped to the current user
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  # Unified `before_action` hook that checks both action-specific and controller-wide rules.
  #
  # Action-specific authorization takes precedence over controller-wide authorization.
  #
  # @raise [AccessDeniedError] If the user is not authorized
  # @return [void]
  def authorize_combined_context!
    # First check per-action rule
    if self.class.action_authorization_map.key?(action_name.to_sym)
      module_key, action_key = self.class.action_authorization_map[action_name.to_sym]
      return current_ability.authorize!(module_key, action_key)
    end

    # Fallback to controller-wide rule if set
    if self.class.authorization_context.present?
      module_key, action_key = self.class.authorization_context
      return current_ability.authorize!(module_key, action_key)
    end
  end
end
