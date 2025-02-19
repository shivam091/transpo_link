# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"
require "generator_spec"
require "generators/presenter/presenter_generator"

RSpec.describe PresenterGenerator, type: :generator do
  destination test_directory_path
  arguments %w[Users::Preference user_preference]

  before(:all) do
    run_generator
  end

  it "creates a presenter file with correct path and name" do
    expect(File).to exist(File.join(destination_root, "app/presenters/users/preference_presenter.rb"))
  end

  it "creates an RSpec test file for the presenter" do
    expect(File).to exist(File.join(destination_root, "spec/presenters/users/preference_presenter_spec.rb"))
  end

  it "ensures generated presenter class does not append 'Presenter' if already included" do
    content = File.read(File.join(destination_root, "app/presenters/users/preference_presenter.rb"))
    expect(content).to match(/class Users::PreferencePresenter < ApplicationPresenter/)
  end

  it "includes the specified method names inside the presenter class" do
    content = File.read(File.join(destination_root, "app/presenters/users/preference_presenter.rb"))
    expect(content).to include("presents :user_preference")
  end

  it "creates a valid presenter test file" do
    content = File.read(File.join(destination_root, "spec/presenters/users/preference_presenter_spec.rb"))
    expect(content).to include("RSpec.describe Users::PreferencePresenter, type: :presenter")
  end
end
