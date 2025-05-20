# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PermissionsHelper
  # Lazily initializes and returns the current user's ability object.
  #
  # @return [Ability] The ability instance scoped to the current user
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  # Check if current user can perform the action in views
  #
  # @param label_key [String] the key of the module
  # @return [String] translated text of the module
  def translate_module(label_key)
    I18n.t(label_key, scope: "permissions.modules")
  end

  # Check if current user can perform the action in views
  #
  # @param label_key [String] the key of the action
  # @return [String] translated text of the action
  def translate_action(label_key)
    I18n.t(label_key, scope: "permissions.actions")
  end

  # Check if current user can perform the action in views
  #
  # @param module_key [String] the key of the module
  # @param action_key [String] the key of the action
  # @return [Boolean] true if the user can view the link, otherwise false
  #
  # @example
  #   <% if authorized_for?(:orders, :update) %>
  #     <%= link_to "Edit", edit_order_path(order) %>
  #   <% end %>
  def authorized_for?(module_key, action_key)
    current_ability.can?(module_key, action_key)
  end

  # Conditionally render content if user is authorized
  #
  # @param module_key [String] the key of the module
  # @param action_key [String] the key of the action
  # @param block [Proc] the block to be executed if the user has access
  #
  # @example
  #   <% with_permission(:orders, :delete) do %>
  #     <%= link_to "Delete", order_path(order), method: :delete %>
  #   <% end %>
  def with_permission(module_key, action_key, &block)
    block.call if authorized_for?(module_key, action_key)
  end
end
