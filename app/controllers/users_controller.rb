# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UsersController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_user, only: :show
  before_action :set_users, only: :index

  requires_authorization_for :show, :users, :view

  # GET /users
  def index
    @users, @pagination_metadata = @users.paginate(page: params[:page])
  end

  # GET /users/:id
  def show
    add_breadcrumb @user.full_name, user_path(@user)
  end

  private

  def set_user
    @user ||= User.find(params[:id])
  end

  def set_users
    @users = User.includes(:role, :user_detail)
    @users = case params[:status]
     when "active"
       require_authorization :users, :view_active
       @users.active
     when "inactive"
       require_authorization :users, :view_inactive
       @users.inactive
     when "suspended"
       require_authorization :users, :view_suspended
       @users.suspended
     else
       require_authorization :users, :view_all
       @users
     end
  end

  def set_breadcrumbs
    add_breadcrumb t("users.breadcrumb"), users_path
  end
end
