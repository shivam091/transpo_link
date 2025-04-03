# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/breadcrumbs_spec.rb

require "spec_helper"

RSpec.describe "Breadcrumbs", type: :request do
  let!(:controller_name) { "AnonymousController" }
  let!(:controller_class) do
    Class.new(ActionController::Base) do
      include Breadcrumbs

      add_breadcrumb :anonymous, :anonymous_path

      def test_breadcrumbs
        add_breadcrumb t("breadcrumbs.home"), "/"
        add_breadcrumb -> { "Dynamic Page" }, -> { "/dynamic-url" }

        render plain: "OK"
      end

      private

      def anonymous
        "Anonymous method"
      end
    end
  end

  before do
    stub_const(controller_name, controller_class)
    controller_class.define_singleton_method(:controller_name) { "anonymous" }
    controller_class.define_singleton_method(:controller_path) { "anonymous" }

    Rails.application.routes.draw do
      get "/anonymous", to: "anonymous#test_breadcrumbs"
    end

    I18n.backend.store_translations(:en, {
      breadcrumbs: {
        home: "Home"
      }
    })
  end

  after do
    Rails.application.reload_routes!
    I18n.backend.reload!
  end

  context "when adding breadcrumbs" do
    before { get "/anonymous", params: {id: 123} }

    it "adds a breadcrumb with a static label and URL" do
      expect(controller_assigns(:breadcrumbs)).to include({label: "Home", url: "/"})
    end

    it "adds a breadcrumb with a localized label and path helper URL" do
      expect(controller_assigns(:breadcrumbs)).to include({label: "Anonymous method", url: "/anonymous"})
    end

    it "adds a breadcrumb with a dynamic label and URL using a Proc" do
      expect(controller_assigns(:breadcrumbs)).to include({label: "Dynamic Page", url: "/dynamic-url"})
    end
  end

  context "when rendering breadcrumbs" do
    let(:dummy_breadcrumbs) do
      [
        {label: "Home", url: "/"},
        {label: "Anonymous", url: "/anonymous"},
        {label: "Dynamic Page", url: nil}
      ]
    end

    before do
      allow_any_instance_of(controller_class).to receive(:breadcrumbs) { dummy_breadcrumbs }
    end

    it "renders the correct breadcrumb structure" do
      rendered_html = controller_class.new.view_context.render_breadcrumbs

      expect(rendered_html).to include("<nav aria-label=\"Breadcrumb\">")
      expect(rendered_html).to include("<ol class=\"breadcrumb\">")
      expect(rendered_html).to include("<li class=\"breadcrumb-item\"><a href=\"/\">Home</a></li>")
      expect(rendered_html).to include("<li class=\"breadcrumb-item\"><a href=\"/anonymous\">Anonymous</a></li>")
      expect(rendered_html).to include("<li class=\"breadcrumb-item active\" aria-current=\"page\">Dynamic Page</li>")
    end
  end
end
