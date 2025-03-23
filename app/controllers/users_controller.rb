# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UsersController < ApplicationController
  add_breadcrumb :users, :users_path

  before_action :find_user, only: :show

  # GET /users
  def index
    @users = User.includes(:role, :user_detail)
    @users = case params[:status]
             when "active"    then @users.active
             when "inactive"  then @users.inactive
             when "suspended" then @users.suspended
             else                  @users
             end
    @users, @pagination_metadata = @users.paginate(page: params[:page])
  end

  # GET /users/:id
  def show
    add_breadcrumb @user.full_name, user_path(@user)
  end

  private

  def find_user
    @user ||= User.find(params[:id])
  end
end
