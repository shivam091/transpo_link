# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/images_helper_spec.rb

require "spec_helper"

RSpec.describe ImagesHelper, type: :helper do
  let!(:svg_file_path) { Rails.root.join("app", "assets", "images", "test.svg") }
  let!(:svg_content) do
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="40" />
      </svg>
    SVG
  end

  before do
    FileUtils.mkdir_p(File.dirname(svg_file_path))
    File.write(svg_file_path, svg_content)
  end

  after { File.delete(svg_file_path) if File.exist?(svg_file_path) }

  describe "#external_svg_tag" do
    context "when options are not provided" do
      let(:result) { helper.external_svg_tag("test.svg") }

      it "renders the SVG with default attributes" do
        expect(result).to include("height=\"24px\"")
        expect(result).to include("width=\"24px\"")
        expect(result).to include("<circle cx=\"50\" cy=\"50\" r=\"40\"")
      end
    end

    context "when options are provided" do
      let(:result) { helper.external_svg_tag("test.svg", height: "40px", fill: "red") }

      it "overrides default attributes with provided options" do
        expect(result).to include("height=\"40px\"")
        expect(result).to include("fill=\"red\"")
      end
    end

    context "when data attributes are provided in options" do
      let(:result) { helper.external_svg_tag("test.svg", data: {toggle: "tooltip", placement: "top"}) }

      it "adds data attributes when provided in options" do
        expect(result).to include("data-toggle=\"tooltip\"")
        expect(result).to include("data-placement=\"top\"")
      end
    end
  end
end
