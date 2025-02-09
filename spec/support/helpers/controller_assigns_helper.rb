# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Provides helper methods to access instance variables assigned in controller actions.
# This is particularly useful in request specs where direct access to controller
# instance variables is not available.
#
# @example Retrieve all assigned variables:
#   assigns = controller_assigns
#   expect(assigns[:user]).to eq(expected_user)
#
# @example Retrieve a specific assigned variable:
#   user = controller_assigns(:user)
#   expect(user).to eq(expected_user)
#
module ControllerAssignsHelper

  # Retrieves instance variables assigned in the controller action.
  #
  # @param key [String, Symbol, nil] The name of the instance variable to retrieve.
  #   If `nil`, returns a hash of all assigned variables.
  #
  # @return [Object, Hash] Returns the value of the specified instance variable,
  #   or a hash of all assigned variables if no key is provided.
  #
  # @example Retrieve all variables:
  #   controller_assigns # => { user: <User>, post: <Post>, ... }
  #
  # @example Retrieve a specific variable:
  #   controller_assigns(:user) # => <User>
  #
  def controller_assigns(key = nil)
    ivars = {}.with_indifferent_access
    @controller.view_assigns.each { |k, v| ivars.regular_writer(k, v) }
    key.nil? ? ivars : ivars[key]
  end
end
