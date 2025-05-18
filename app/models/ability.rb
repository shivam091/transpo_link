# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Handles user-specific authorization logic by mapping actions and modules
# to permission records associated with the user's role.
#
# This class is intended to be used for checking access rights at runtime.
#
# @example
#   ability = Ability.new(current_user)
#   ability.can?("orders", "create")     # => true or false
#   ability.authorize!("orders", "edit") # raises AccessDeniedError if unauthorized
class Ability
  # Maps Rails-style actions to normalized permission keys
  #
  # @return [Hash{String => String}]
  ACTION_ALIASES = {
  }.freeze

  # Initializes a new Ability instance with a given user.
  #
  # @param user [User] The user whose permissions are to be evaluated.
  def initialize(user)
    @user = user
    load_permissions
  end

  # Determines whether the user is allowed to perform a given action on a module.
  #
  # @param module_key [String, Symbol] The label key of the module (e.g., "orders").
  # @param action_key [String, Symbol] The action label (e.g., "edit", "create").
  # @return [Boolean] True if permission is allowed, false otherwise.
  def can?(module_key, action_key)
    key = [module_key.to_s.downcase, ACTION_ALIASES[action_key.to_s.downcase] || action_key.to_s.downcase]

    @can_cache ||= {}
    @can_cache[key] ||= @permissions[key] == true
  end

  # Enforces permission by raising an error if the user is not allowed to perform the action.
  #
  # @param module_key [String, Symbol] The label key of the module.
  # @param action_key [String, Symbol] The action label.
  # @raise [AccessDeniedError] If the user is not authorized to perform the action.
  # @return [void]
  def authorize!(module_key, action_key)
    raise AccessDeniedError.new(module_key, action_key) unless can?(module_key, action_key)
  end

  private

  # Loads the permissions into an internal cache, using Rails' caching for performance.
  #
  # @return [void]
  def load_permissions
    @permissions ||= Rails.cache.fetch(["user_permissions", @user.role_id], expires_in: 15.minutes) do
      load_permissions_from_db
    end
  end

  # Fetches role-based permissions directly from the database and formats them into a hash.
  #
  # @return [Hash{Array(String, String) => Boolean}] A hash with normalized [module_key, action_key] => is_allowed.
  def load_permissions_from_db
    permissions = {}

    @user.role.role_permissions
         .joins(permission: %i[module action])
         .select(
           "access_control_modules.label_key AS module_key",
           "access_control_actions.label_key AS action_key",
           "access_control_role_permissions.is_allowed"
         )
         .each do |record|
           key = [record.module_key.downcase, record.action_key.downcase]
           permissions[key] = record.is_allowed
         end

    permissions
  end
end
