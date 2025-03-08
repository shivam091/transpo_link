# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RolesController < ApplicationController
  # GET /roles
  def index
    @roles = Role.all
  end
end
