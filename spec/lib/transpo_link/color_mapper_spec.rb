# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/color_mapper_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::ColorMapper do
  before do
    stub_const("TranspoLink::ColorMapper::COLOR_MAPS", {
      "status" => {
        "approved" => "#FAFAFAFF",
        "draft" => "#CCCCCCFF"
      },
      "tax_type" => {
        "vat" => "#123456FF"
      }
    }.freeze)
  end

  describe "#for" do
    context "when an unknown type is used" do
      let(:mapper) { described_class.new(:non_existing_type) }

      it "returns default color for any type" do
        expect(mapper.for(:anything)).to eq("#D3D3D3FF")
      end
    end

    context "when an unknown key is used" do
      let(:mapper) { described_class.new(:status) }

      it "returns default color for any key" do
        expect(mapper.for(:anything)).to eq("#D3D3D3FF")
      end
    end

    context "when a known type and key is used" do
      let(:mapper) { described_class.new(:status) }

      it "returns the correct color" do
        expect(mapper.for(:approved)).to eq("#FAFAFAFF")
      end
    end
  end
end
