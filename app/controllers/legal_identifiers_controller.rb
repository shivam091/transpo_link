# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LegalIdentifiersController < ApplicationController

  before_action :legal_identifiers
  before_action :find_legal_identifier, except: [:index, :new, :create]

  # GET /tax-details
  def index
    @legal_identifiers, @pagination_metadata = @legal_identifiers.paginate(page: params[:page])
  end

  # GET /tax-details/new
  def new
    @legal_identifier = @legal_identifiers.build
  end

  # POST /tax-details
  def create
    response = LegalIdentifiers::CreateService.(current_user, legal_identifier_params)
    @legal_identifier = response.payload[:legal_identifier]
    if response.success?
      flash[:notice] = response.message
      redirect_to legal_identifiers_path, status: :see_other
    else
      flash.now[:alert] = response.message
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

  # GET /tax-details/:id/edit
  def edit
  end

  # PUT|PATCH /tax-details/:id/edit
  def update
    response = LegalIdentifiers::UpdateService.(@legal_identifier, legal_identifier_params)
    @legal_identifier = response.payload[:legal_identifier]
    if response.success?
      flash[:notice] = response.message
      redirect_to legal_identifiers_path, status: :see_other
    else
      flash.now[:alert] = response.message
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

  # DELETE /tax-details/:id
  def destroy
    response = LegalIdentifiers::DestroyService.(@legal_identifier)
    @legal_identifier = response.payload[:legal_identifier]
    if response.success?
      flash[:info] = response.message
    else
      flash[:alert] = response.message
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
    @legal_identifier = @legal_identifiers.find(params[:id])
  end
end
