# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module providing shareable scopes and methods for activating and
# deactivating objects.
module Toggleable
  extend ActiveSupport::Concern

  ACTIONS = %i[activate deactivate].freeze
  CALLBACK_TYPES = %i[before around after].freeze

  included do
    attribute :is_active, :boolean, default: false

    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }

    define_model_callbacks(*ACTIONS)

    ACTIONS.each do |action|
      define_method(action) do
        self.class.transaction do
          run_callbacks(action) { update!(is_active: (action == :activate)) }
        end
      end

      CALLBACK_TYPES.each do |callback_type|
        define_singleton_method("#{callback_type}_#{action}") do |*args, &block|
          set_callback(action, callback_type, *args, &block)
        end
      end
    end
  end

  class_methods do
    ACTIONS.each do |action|
      define_method(action) do
        all.each { |record| record.public_send(action) }
      end
    end
  end
end
