# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/badges_helper_spec.rb

require "spec_helper"

RSpec.describe BadgesHelper, type: :helper do
  describe "#badge_tag" do
    it "renders badge with color and correct CSS variables" do
      html = helper.badge_tag("Hello", color: "#ff00aa")

      expect(html).to have_selector("span",
        class: "badge square-pill",
        style: "--label-r: 255;--label-g: 0;--label-b: 170;--label-h: 320;--label-s: 100;--label-l: 50",
        text: "Hello"
      )
    end

    it "renders badge with alpha from 8-digit hex color" do
      html = helper.badge_tag("Hello", color: "#ff00aa80")

      expect(html).to have_selector("span",
        class: "badge square-pill",
        style: "--label-r: 255;--label-g: 0;--label-b: 170;--label-h: 320;--label-s: 100;--label-l: 50",
        text: "Hello"
      )
    end

    it "renders square badge when shape is not specified" do
      html = helper.badge_tag("Square", color: "#ff00aa80")

      expect(html).to have_selector("span", class: "badge square-pill", text: "Square")
    end

    it "renders rounded badge when shape is :rounded" do
      html = helper.badge_tag("Round", color: "#ff00aa80", shape: :rounded)

      expect(html).to have_selector("span", class: "badge rounded-pill", text: "Round")
    end

    it "renders badge with icon and text" do
      html = helper.badge_tag("Status", color: "#ff00aa80", icon: "check")

      expect(html).to have_selector("span", class: "badge square-pill", text: "Status")
      expect(html).to have_selector("svg", class: "icon icon-check")
    end

    it "renders icon-only badge" do
      html = helper.badge_tag("info", color: "#ff00aa80", icon: "info-circle", icon_only: true)

      expect(html).to have_selector("span[aria-label='info'][role='img']", class: "badge square-pill", text: "")
      expect(html).to have_selector("svg", class: "icon icon-info-circle")
    end

    it "renders link badge if href is provided" do
      html = helper.badge_tag("Link", {color: "#ff00aa80"}, {href: "/dashboard"})

      expect(html).to have_selector("a[href='/dashboard']", class: "badge square-pill", text: "Link")
    end

    it "accepts custom HTML classes" do
      html = helper.badge_tag("Styled", {color: "#ff00aa80"}, {class: "custom-class"})

      expect(html).to have_selector("span", class: "badge square-pill custom-class", text: "Styled")
    end

    it "renders badge with block content" do
      html = helper.badge_tag(color: "#ff00aa80") { "From Block" }

      expect(html).to have_selector("span", class: "badge square-pill", text: "From Block")
    end

    it "renders badge with icon and block content" do
      html = helper.badge_tag(color: "#ff00aa80", icon: "star") { "Favorite" }

      expect(html).to have_selector("span", class: "badge square-pill", text: "Favorite")
      expect(html).to have_selector("svg", class: "icon icon-star")
    end

    it "renders badge with custom data attributes" do
      html = helper.badge_tag("Custom", {color: "#ff00aa80"}, {data: {status: "ok"}})

      expect(html).to have_selector("span[data-status='ok']", class: "badge square-pill", text: "Custom")
    end

    it "renders badge with custom tag" do
      html = helper.badge_tag("Div Badge", {color: "#ff00aa80"}, {tag: :div})

      expect(html).to have_selector("div", class: "badge square-pill", text: "Div Badge")
    end

    it "renders empty badge when label is nil and no block is given" do
      html = helper.badge_tag(nil, color: "#ff00aa80")

      expect(html).to have_selector("span", class: "badge square-pill", text: "")
    end

    it "renders icon-only badge as a link when href is given" do
      html = helper.badge_tag("Home", {color: "#ff00aa80", icon: "home", icon_only: true}, {href: "/home"})

      expect(html).to have_selector("a[aria-label='Home'][href='/home']", class: "badge square-pill", text: "")
      expect(html).to have_selector("svg", class: "icon icon-home")
    end

    it "falls back to span if invalid tag is passed" do
      html = helper.badge_tag("Nope", {color: "#ff00aa80"}, {tag: :script})

      expect(html).to have_selector("span", class: "badge square-pill", text: "Nope")
    end

    it "does not respect tag if href is given" do
      html = helper.badge_tag("Link", {color: "#ff00aa80"}, {tag: :div, href: "/dashboard"})

      expect(html).to have_selector("a[href='/dashboard']", class: "badge square-pill", text: "Link")
    end
  end
end
