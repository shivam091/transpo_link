# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  before_action :redirect_if_credentials_missing, only: :create

  # GET /users/sign-in
  # def new
  #   super
  # end

  # POST /users/sign-in
  def create
    resource_class.without_timestamps do
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in, user_name: resource.full_name)
      sign_in(resource_name, resource, event: :authentication)
      yield resource if block_given?

      if resource.reset_password_token.present?
        resource.update_columns(reset_password_token: nil, reset_password_sent_at: nil)
      end
    end
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /users/sign-out
  def destroy
    resource_class.without_timestamps do
      super
    end
  end

  private

  def redirect_if_credentials_missing
    if params[:user][:email].blank? || params[:user][:password].blank?
      set_flash_message!(:alert, :missing_email_or_password)
      redirect_to new_session_path(resource_name) and return
    end
  end

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
