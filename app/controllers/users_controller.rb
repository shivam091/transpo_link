# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UsersController < ApplicationController

  before_action :find_user, only: :show

  # GET /users
  def index
    @users = User.includes(:user_detail)
    @users, @pagination_data = @users.paginate(page: params[:page])
  end

  # GET /users/:id
  def show
  end

  private

  def find_user
    @user = User.find(params[:id])
  end
end
