# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProfilesController < ApplicationController
  before_action :set_breadcrumbs, :set_user

  requires_authorization_for [:edit, :update], :profiles, :update
  requires_authorization_for :show, :profiles, :view

  # GET /profile
  def show
  end

  # GET /profile/edit
  def edit
    add_breadcrumb t(".breadcrumb"), edit_profile_path(current_user)
  end

  # PUT|PATCH /profile
  def update
    response = Profiles::UpdateService.(current_user, profile_params)

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to profile_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      user_detail_attributes: [
        :first_name,
        :last_name,
        :mobile_number,
        :alternate_contact_number,
        :alternate_email
      ],
      address_attributes: [
        :address1,
        :address2,
        :city,
        :state,
        :country,
        :postal_code
      ]
    )
  end

  def set_breadcrumbs
    add_breadcrumb t("profiles.breadcrumb"), profile_path
  end

  def set_user
    @user = current_user
  end

  def form_frame_id
    :edit_profile_form_frame
  end

  def form_partial
    "profiles/form"
  end
end
