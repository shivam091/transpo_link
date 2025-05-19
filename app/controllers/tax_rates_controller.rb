# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRatesController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_tax_rate, only: [:edit, :update, :destroy]
  before_action :set_tax_rates, only: :index

  requires_authorization_for [:new, :create], :tax_rates, :create
  requires_authorization_for [:edit, :update], :tax_rates, :update
  requires_authorization_for :destroy, :tax_rates, :delete

  # GET /tax-rates
  def index
    @tax_rates, @pagination_metadata = @tax_rates.paginate(page: params[:page])
  end

  # GET /tax-rates/new
  def new
    add_breadcrumb t(".breadcrumb"), new_tax_rate_path
    @tax_rate = TaxRate.new
  end

  # POST /tax-rates
  def create
    response = TaxRates::CreateService.(tax_rate_params)
    @tax_rate = response.payload[:tax_rate]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to tax_rates_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /tax-rates/:id/edit
  def edit
    add_breadcrumb t(".breadcrumb"), edit_tax_rate_path(@tax_rate)
  end

  # PUT|PATCH /tax-rates/:id
  def update
    response = TaxRates::UpdateService.(@tax_rate, tax_rate_params)
    @tax_rate = response.payload[:tax_rate]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to tax_rates_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /tax-rates/:id
  def destroy
    response = TaxRates::DestroyService.(@tax_rate)
    @tax_rate = response.payload[:tax_rate]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to tax_rates_path, status: :see_other
  end

  private

  def tax_rate_params
    params.require(:tax_rate).permit(
      :tax_identifier_type,
      :country,
      :tax_type,
      :business_category,
      :rate,
      :valid_from,
      :valid_to
    )
  end

  def set_tax_rate
    @tax_rate ||= TaxRate.find(params[:id])
  end

  def set_tax_rates
    case params[:status]
    when "active"
      require_authorization :tax_rates, :view_active
      @tax_rates ||= TaxRate.active
    when "future"
      require_authorization :tax_rates, :view_future
      @tax_rates ||= TaxRate.future
    when "expired"
      require_authorization :tax_rates, :view_expired
      @tax_rates ||= TaxRate.expired
    else
      require_authorization :tax_rates, :view_all
      @tax_rates ||= TaxRate.all
    end

    @tax_rates
  end

  def set_breadcrumbs
    add_breadcrumb t("tax_rates.breadcrumb"), tax_rates_path
  end

  def form_frame_id
    action_name == "create" ? :new_tax_rate_form_frame : :edit_tax_rate_form_frame
  end

  def form_partial
    "tax_rates/form"
  end
end
