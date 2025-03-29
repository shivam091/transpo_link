# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/presenters/application_presenter_spec.rb

require "spec_helper"

RSpec.describe ApplicationPresenter do
  let(:model) { double("Model", name: "Test Model") }
  let(:view_context) { double("view_context") }

  let!(:presenter_class) do
    Class.new(ApplicationPresenter) do
      presents :model
    end
  end
  let!(:presenter) { presenter_class.new(model, view_context) }

  describe "#initialize" do
    it "assigns the model and view context" do
      expect(presenter.instance_variable_get(:@model)).to eq(model)
      expect(presenter.instance_variable_get(:@view)).to eq(view_context)
    end
  end

  describe "#view_context" do
    it "returns the view context" do
      expect(presenter.view_context).to eq(view_context)
    end
  end

  describe "delegation" do
    it "delegates method calls to the model" do
      expect(presenter.name).to eq("Test Model")
    end
  end

  describe ".presents" do
    it "defines a method that returns the model" do
      expect(presenter.model).to eq(model)
    end
  end
end
