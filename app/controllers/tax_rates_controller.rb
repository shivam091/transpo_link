# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRatesController < ApplicationController

  before_action :find_tax_rate, only: [:edit, :update, :destroy]

  # GET /tax-rates
  def index
    @tax_rates = TaxRate.all
    @tax_rates, @pagination_metadata = @tax_rates.paginate(page: params[:page])
  end

  # GET /tax-rates/new
  def new
    @tax_rate = TaxRate.new
  end

  # POST /tax-rates
  def create
    response = TaxRates::CreateService.(tax_rate_params)
    @tax_rate = response.payload[:tax_rate]
    if response.success?
      flash[:notice] = response.message
      redirect_to tax_rates_path, status: :see_other
    else
      flash.now[:alert] = response.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_tax_rate_form_frame, partial: "tax_rates/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /tax-rates/:id/edit
  def edit
  end

  # PUT|PATCH /tax-rates/:id/edit
  def update
    response = TaxRates::UpdateService.(@tax_rate, tax_rate_params)
    @tax_rate = response.payload[:tax_rate]
    if response.success?
      flash[:notice] = response.message
      redirect_to tax_rates_path, status: :see_other
    else
      flash.now[:alert] = response.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_tax_rate_form_frame, partial: "tax_rates/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /tax-rates/:id
  def destroy
    response = TaxRates::DestroyService.(@tax_rate)
    @tax_rate = response.payload[:tax_rate]
    if response.success?
      flash[:info] = response.message
    else
      flash[:alert] = response.message
    end
    redirect_to tax_rates_path, status: :see_other
  end

  private

  def tax_rate_params
    params.require(:tax_rate).permit(:tax_type, :country, :rate, :valid_from, :valid_to)
  end

  def find_tax_rate
    @tax_rate = TaxRate.find(params[:id])
  end
end
