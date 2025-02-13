# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.includes(:user_detail)
    @users, @pagination_data = @users.paginate(params[:page])
  end
end
