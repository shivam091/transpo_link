# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumBatchProcessingStatuses < ActiveRecord::Migration[8.0]
  def change
    create_enum :batch_processing_statuses,
                %i[
                  pending
                  queued
                  processing
                  succeeded
                  failed
                ]
  end
end
