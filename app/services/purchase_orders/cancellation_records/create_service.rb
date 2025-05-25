# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::CancellationRecords::CreateService < ApplicationService
  def initialize(cancellable, cancellation_record_attributes)
    @cancellable = cancellable
    @cancellation_record_attributes = cancellation_record_attributes
  end

  def call
    create_cancellation_record
  end

  private

  attr_reader :cancellable, :cancellation_record_attributes

  def create_cancellation_record
    cancellation_record = cancellable.build_cancellation_record(cancellation_record_attributes)

    if cancellation_record.save
      ServiceResponse.success(payload: {cancellation_record:})
    else
      ServiceResponse.error(payload: {cancellation_record:})
    end
  end
end
