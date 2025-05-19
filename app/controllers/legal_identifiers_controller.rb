# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiersController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_legal_identifiers, only: :index
  before_action :set_legal_identifier, except: [:index, :new, :create]

  requires_authorization_for [:new, :create], :legal_identifiers, :create
  requires_authorization_for [:edit, :update], :legal_identifiers, :update
  requires_authorization_for :destroy, :legal_identifiers, :delete
  requires_authorization_for :approve, :legal_identifiers, :approve
  requires_authorization_for :reject, :legal_identifiers, :reject

  # GET /legal-identifiers
  def index
    @legal_identifiers, @pagination_metadata = @legal_identifiers.paginate(page: params[:page])
  end

  # GET /legal-identifiers/new
  def new
    @legal_identifier = LegalIdentifier.new
  end

  # POST /legal-identifiers
  def create
    response = LegalIdentifiers::CreateService.(current_user, legal_identifier_params)
    @legal_identifier = response.payload[:legal_identifier]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to legal_identifiers_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /legal-identifiers/:id/edit
  def edit
  end

  # PUT|PATCH /legal-identifiers/:id
  def update
    response = LegalIdentifiers::UpdateService.(@legal_identifier, legal_identifier_params)
    @legal_identifier = response.payload[:legal_identifier]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to legal_identifiers_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /legal-identifiers/:id
  def destroy
    response = LegalIdentifiers::DestroyService.(@legal_identifier)
    @legal_identifier = response.payload[:legal_identifier]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to legal_identifiers_path, status: :see_other
  end

  # PATCH /legal-identifiers/:id/approve
  def approve
    response = LegalIdentifiers::ApproveService.(@legal_identifier)
    @legal_identifier = response.payload[:legal_identifier]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to legal_identifiers_path, status: :see_other
  end

  # PATCH /legal-identifiers/:id/reject
  def reject
    response = LegalIdentifiers::RejectService.(@legal_identifier)
    @legal_identifier = response.payload[:legal_identifier]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to legal_identifiers_path, status: :see_other
  end

  private

  def legal_identifier_params
    params.require(:legal_identifier).permit(
      :country,
      :entity_type,
      :tax_identifier_type,
      :tax_identifier,
      :business_identifier_type,
      :business_identifier,
    )
  end

  def set_legal_identifier
    @legal_identifier ||= LegalIdentifier.find(params[:id])
  end

  def set_legal_identifiers
    @legal_identifiers ||= LegalIdentifier.accessible(current_user)

    case params[:status]
    when "unapproved"
      require_authorization :legal_identifiers, :view_unapproved
      @legal_identifiers = @legal_identifiers.unapproved
    when "approved"
      require_authorization :legal_identifiers, :view_approved
      @legal_identifiers = @legal_identifiers.approved
    when "rejected"
      require_authorization :legal_identifiers, :view_rejected
      @legal_identifiers = @legal_identifiers.rejected
    else
      require_authorization :legal_identifiers, :view_all
    end

    @legal_identifiers
  end

  def set_breadcrumbs
    add_breadcrumb t("legal_identifiers.breadcrumb"), legal_identifiers_path
  end

  def form_frame_id
    action_name == "create" ? :new_legal_identifier_form_frame : :edit_legal_identifier_form_frame
  end

  def form_partial
    "legal_identifiers/form"
  end
end
