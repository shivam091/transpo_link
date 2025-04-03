# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class StatesController < ApplicationController

  skip_before_action :authenticate_user!

  # GET /states
  def index
    @states = TranspoLink::CountryInfo.new(params[:country_code]).select_subdivision_options
    @target = params[:target]

    respond_to do |format|
      format.turbo_stream
    end
  end
end
