# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Users::PasswordsController < Devise::PasswordsController
  before_action :throttle_password_reset, only: :create

  # GET /users/password/new
  def new
    super
  end

  # POST /users/password
  def create
    User.without_timestamps do
      super
    end
  end

  # GET /users/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /users/password
  def update
    super
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

  def throttle_password_reset
    self.resource = User.with_email(user_params[:email])

    if user&.recently_sent_password_reset_instructions?
      flash[:alert] = t(:throttle_reset, scope: translation_scope, count: (User::THROTTLE_RESET_PERIOD / 60))
      redirect_to new_session_path(resource) and return
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
