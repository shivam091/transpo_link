# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxDetailsController < ApplicationController

  before_action :tax_details

  # GET /tax-details
  def index
    @tax_details, @pagination_metadata = @tax_details.paginate(page: params[:page])
  end

  private

  def tax_details
    @tax_details ||= TaxDetail.accessible(current_user)
  end
end
