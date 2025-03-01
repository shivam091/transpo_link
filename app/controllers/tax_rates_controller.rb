# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRatesController < ApplicationController

  # GET /tax-rates
  def index
    @tax_rates = TaxRate.all
    @tax_rates, @pagination_metadata = @tax_rates.paginate(page: params[:page])
  end
end
