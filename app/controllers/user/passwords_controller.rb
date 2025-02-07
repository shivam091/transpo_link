# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class User::PasswordsController < Devise::PasswordsController
  # GET /users/password/new
  # def new
  #   super
  # end

  # POST /users/password
  def create
    resource_class.without_timestamps do
      super
    end
  end

  # GET /users/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /users/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
