# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/presenters_helper_spec.rb

require "spec_helper"

RSpec.describe PresentersHelper, type: :helper do
  before(:all) do
    class PresentableModel
      include Presentable
    end

    class PresentableModelPresenter
      attr_reader :model, :view_context

      def initialize(model, view_context)
        @model = model
        @view_context = view_context
      end

      def model_name
        @model.class.name
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :PresentableModel)
    Object.send(:remove_const, :PresentableModelPresenter)
  end

  let!(:presentable_model) { PresentableModel.new }

  describe "#present" do
    it "returns an instance of the correct presenter" do
      presenter = nil
      helper.present(presentable_model) { |p| presenter = p }

      expect(presenter).to be_a(PresentableModelPresenter)
    end

    it "passes the correct model to the presenter" do
      presenter = nil
      helper.present(presentable_model) { |p| presenter = p }

      expect(presenter.model).to eq(presentable_model)
    end

    it "provides access to the view context" do
      presenter = nil
      helper.present(presentable_model) { |p| presenter = p }

      expect(presenter.view_context).to eq(helper)
    end
  end
end
