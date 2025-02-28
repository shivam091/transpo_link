# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetailsController < ApplicationController

  before_action :tax_details
  before_action :find_tax_detail, except: [:index, :new, :create]

  # GET /tax-details
  def index
    @tax_details, @pagination_metadata = @tax_details.paginate(page: params[:page])
  end

  # GET /tax-details/new
  def new
    @tax_detail = @tax_details.build
  end

  # POST /tax-details
  def create
    response = TaxDetails::CreateService.(current_user, tax_detail_params)
    @tax_detail = response.payload[:tax_detail]
    if response.success?
      flash[:notice] = response.message
      redirect_to tax_details_path, status: :see_other
    else
      flash.now[:alert] = response.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_tax_detail_form, partial: "tax_details/form"),
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
    response = TaxDetails::UpdateService.(@tax_detail, tax_detail_params)
    @tax_detail = response.payload[:tax_detail]
    if response.success?
      flash[:notice] = response.message
      redirect_to tax_details_path, status: :see_other
    else
      flash.now[:alert] = response.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_tax_detail_form_frame, partial: "tax_details/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /tax-details/:id
  def destroy
    response = TaxDetails::DestroyService.(@tax_detail)
    @tax_detail = response.payload[:tax_detail]
    if response.success?
      flash[:info] = response.message
    else
      flash[:alert] = response.message
    end
    redirect_to tax_details_path, status: :see_other
  end

  private

  def tax_detail_params
    params.require(:tax_detail).permit(:tax_type, :tax_number, :country)
  end

  def tax_details
    @tax_details ||= TaxDetail.accessible(current_user)
  end

  def find_tax_detail
    @tax_detail = @tax_details.find(params[:id])
  end
end
