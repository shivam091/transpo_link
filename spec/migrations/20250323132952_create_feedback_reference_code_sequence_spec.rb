# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/migrations/20250323132952_create_feedback_reference_code_sequence_spec.rb

require "spec_helper"
require_migration!

RSpec.describe CreateFeedbackReferenceCodeSequence do
  let(:sequence_name) { "feedback_reference_code_seq" }

  describe ".up" do
    before do
      run_migration(:down)
      run_migration(:up)
    end

    it "creates the sequence" do
      expect(sequence_exists?(sequence_name)).to be_truthy
    end

    it "sets ownership of the sequence" do
      expect(sequence_ownership(sequence_name)).to eq(
        "table_name" => "feedbacks",
        "column_name" => "reference_code"
      )
    end
  end

  describe ".down" do
    before { run_migration(:down) }

    it "drops the sequence" do
      expect(sequence_exists?(sequence_name)).to be_falsy
    end
  end
end
