# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/images_helper_spec.rb

require "spec_helper"

RSpec.describe ImagesHelper, type: :helper do
  describe "#external_svg_tag" do
    let(:svg_file_path) { Rails.root.join("app", "assets", "images", "test.svg") }
    let(:svg_content) do
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

    after do
      File.delete(svg_file_path) if File.exist?(svg_file_path)
    end

    it "renders the SVG with default attributes" do
      result = helper.external_svg_tag("test.svg")
      expect(result).to include("height=\"20px\"")
      expect(result).to include("width=\"20px\"")
      expect(result).to include("fill=\"currentColor\"")
      expect(result).to include("<circle cx=\"50\" cy=\"50\" r=\"40\"")
    end

    it "overrides default attributes with provided options" do
      result = helper.external_svg_tag("test.svg", height: "40px", fill: "red")
      expect(result).to include("height=\"40px\"")
      expect(result).to include("fill=\"red\"")
    end

    it "adds data attributes when provided in options" do
      result = helper.external_svg_tag("test.svg", data: { toggle: "tooltip", placement: "top" })
      expect(result).to include("data-toggle=\"tooltip\"")
      expect(result).to include("data-placement=\"top\"")
    end
  end

  describe "#inline_svg_tag" do
    let(:symbol_id) { "test-icon" }
    let(:fake_image_url) { "/assets/svgs/defs.svg" }

    before do
      allow(helper).to receive(:image_url).and_return(fake_image_url)
    end

    it "renders an inline SVG with default attributes" do
      result = helper.inline_svg_tag(symbol_id)

      expect(result).to include("<svg")
      expect(result).to include("height=\"20px\"")
      expect(result).to include("width=\"20px\"")
      expect(result).to include("fill=\"currentColor\"")
      expect(result).to include("class=\"icon icon-test-icon\"")
      expect(result).to include("xlink:href=\"/assets/svgs/defs.svg#icon-test-icon\"")
    end

    it "applies custom attributes" do
      result = helper.inline_svg_tag(symbol_id, class: "custom-class", fill: "blue")

      expect(result).to include("fill=\"blue\"")
      expect(result).to include("class=\"icon icon-test-icon custom-class\"")
    end
  end

end
