# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RolesController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_role, except: :index
  before_action :set_grouped_permissions, only: [:edit, :show, :update]

  # GET /roles
  def index
    @roles = Role.all
  end

  # GET /roles/:id/edit
  def edit
    add_breadcrumb t(".breadcrumb", name: @role.name), edit_role_path(@role)
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
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
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
    params.require(:role).permit(
      :name,
      :is_active,
      role_permissions_attributes: [
        :id,
        :is_allowed
      ]
    )
  end

  def set_role
    @role ||= Role.find(params[:id])
  end

  def set_grouped_permissions
    @grouped_permissions ||= @role.role_permissions.ordered_by_positions.grouped_by_module
  end

  def set_breadcrumbs
    add_breadcrumb t("roles.breadcrumb"), roles_path
  end

  def form_frame_id
    :edit_role_form_frame
  end

  def form_partial
    "roles/form"
  end
end
