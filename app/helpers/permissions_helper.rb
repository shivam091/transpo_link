# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PermissionsHelper
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
  #   <% if can_view_link?("orders", "update") %>
  #     <%= link_to "Edit", edit_order_path(order) %>
  #   <% end %>
  def can_view_link?(module_key, action_key)
    Ability.new(current_user).can?(module_key, action_key)
  end

  # Conditionally render content if user is authorized
  #
  # @param module_key [String] the key of the module
  # @param action_key [String] the key of the action
  # @param block [Proc] the block to be executed if the user has access
  #
  # @example
  #   <% with_authorization("orders", "delete") do %>
  #     <%= link_to "Delete", order_path(order), method: :delete %>
  #   <% end %>
  def with_authorization(module_key, action_key, &block)
    block.call if can_view_link?(module_key, action_key)
  end
end
