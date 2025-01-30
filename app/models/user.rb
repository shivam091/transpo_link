# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class User < ApplicationRecord
  include Toggleable

  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable

  attribute :is_active, default: false
  attribute :is_banned, default: false

  belongs_to :role

  delegate :name, to: :role, prefix: true
end
