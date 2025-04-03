# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiersController < ApplicationController
  before_action :set_breadcrumbs, :legal_identifiers
  before_action :find_legal_identifier, except: [:index, :new, :create]

  # GET /legal-identifiers
  def index
    @legal_identifiers = case params[:status]
                         when "unapproved" then @legal_identifiers.unapproved
                         when "approved"   then @legal_identifiers.approved
                         when "rejected"   then @legal_identifiers.rejected
                         else                   @legal_identifiers
                         end
    @legal_identifiers, @pagination_metadata = @legal_identifiers.paginate(page: params[:page])
  end

  # GET /legal-identifiers/new
  def new
    @legal_identifier = @legal_identifiers.build
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
          render turbo_stream: [
            turbo_stream.update(:new_legal_identifier_form_frame, partial: "legal_identifiers/form"),
            render_flash
          ], status: :unprocessable_entity
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
          render turbo_stream: [
            turbo_stream.update(:edit_legal_identifier_form_frame, partial: "legal_identifiers/form"),
            render_flash
          ], status: :unprocessable_entity
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

  def legal_identifiers
    @legal_identifiers ||= LegalIdentifier.accessible(current_user)
  end

  def find_legal_identifier
    @legal_identifier ||= @legal_identifiers.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("legal_identifiers.breadcrumb"), legal_identifiers_path
  end
end
