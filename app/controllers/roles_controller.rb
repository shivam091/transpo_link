# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RolesController < ApplicationController
  add_breadcrumb :roles, :roles_path

  before_action :find_role, except: :index

  # GET /roles
  def index
    @roles = Role.all
  end

  # GET /roles/:id/edit
  def edit
    add_breadcrumb :edit, edit_role_path(@role)
  end

  # PUT|PATCH /roles/:id
  def update
    response = Roles::UpdateService.(@role, role_params)
    @role = response.payload[:role]
    if response.success?
      set_flash_message(:notice, :success)
      redirect_to roles_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_role_form_frame, partial: "roles/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /roles/:id
  def show
    add_breadcrumb @role.name, role_path(@role)
  end

  private

  def role_params
    params.require(:role).permit(:name, :is_active)
  end

  def find_role
    @role ||= Role.find(params[:id])
  end
end
