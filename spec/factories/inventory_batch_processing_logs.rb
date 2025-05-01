# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch_processing_log do
    association :inventory_batch
    association :user, factory: :manager
    error_logs { {} }
    status { InventoryBatchProcessingLog.statuses[:pending] }
    metadata { {} }

    trait :pending do
      status { InventoryBatchProcessingLog.statuses[:pending] }
    end

    trait :processing do
      status { InventoryBatchProcessingLog.statuses[:processing] }
    end

    trait :succeeded do
      status { InventoryBatchProcessingLog.statuses[:succeeded] }
    end

    trait :failed do
      status { InventoryBatchProcessingLog.statuses[:failed] }
    end
  end
end
