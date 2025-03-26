# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/presentable_spec.rb

require "spec_helper"

RSpec.describe Presentable do
  before(:all) do
    class PresentableModel
      include Presentable
    end

    class PresentableModelPresenter
      def initialize(model, view_context = nil)
        @model = model
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

  let(:presentable_model) { PresentableModel.new }

  describe "#decorate" do
    it "returns an instance of the corresponding presenter" do
      expect(presentable_model.decorate).to be_a(PresentableModelPresenter)
    end

    it "correctly decorates the model" do
      expect(presentable_model.decorate.model_name).to eq("PresentableModel")
    end
  end
end
