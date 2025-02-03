# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class User::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /users/sign-in
  # def new
  #   super
  # end

  # POST /users/sign-in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in, user_name: resource.full_name)
    sign_in(resource_name, resource, event: :authentication)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /users/sign-out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  protected

  def after_sign_in_path_for(resource)
    redirect_location = stored_location_for(:redirect)
    redirect_location ||= stored_location_for(resource) if resource.present?
    redirect_location || root_path
  end

  def after_sign_out_path_for(resource)
    new_session_path(resource)
  end
end
