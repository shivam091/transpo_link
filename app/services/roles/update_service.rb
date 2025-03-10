# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Roles::UpdateService < ApplicationService
  def initialize(role, role_attributes)
    @role, @role_attributes = role, role_attributes
  end

  def call
    update_role
  end

  private

  attr_reader :role, :role_attributes

  def update_role
    if role.update(role_attributes)
      ServiceResponse.success(payload: {role:})
    else
      ServiceResponse.error(payload: {role:})
    end
  end
end
