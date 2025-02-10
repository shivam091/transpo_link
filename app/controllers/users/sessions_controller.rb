# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  before_action :redirect_if_credentials_missing, only: :create

  # GET /users/sign-in
  def new
    super
  end

  # POST /users/sign-in
  def create
    User.without_timestamps do
      user = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in, user_name: user.full_name)
      sign_in(:user, user, event: :authentication)
      yield user if block_given?

      if user.reset_password_token.present?
        user.update_columns(reset_password_token: nil, reset_password_sent_at: nil)
      end
      respond_with user, location: after_sign_in_path_for(user)
    end
  end

  # DELETE /users/sign-out
  def destroy
    User.without_timestamps do
      super
    end
  end

  private

  def redirect_if_credentials_missing
    if params[:user][:email].blank? || params[:user][:password].blank?
      set_flash_message!(:alert, :missing_email_or_password)
      redirect_to new_session_path(:user) and return
    end
  end

  protected

  def after_sign_in_path_for(user)
    redirect_location = stored_location_for(:redirect)
    redirect_location ||= stored_location_for(user) if user.present?
    redirect_location || root_path
  end

  def after_sign_out_path_for(user)
    new_session_path(user)
  end
end
