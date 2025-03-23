# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateFeedbackReferenceCodeSequence < ActiveRecord::Migration[8.0]
  def change
    create_sequence :feedback_reference_code_seq, owned_by: "feedbacks.reference_code"
  end
end
