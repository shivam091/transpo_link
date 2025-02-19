# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "rails/generators"

class PresenterGenerator < Rails::Generators::NamedBase
  desc "This generator creates a presenter in app/presenters."

  source_root File.expand_path("../templates", __FILE__)

  argument :targets, type: :array, default: []

  check_class_collision suffix: "Presenter"

  def create_presenter_file
    template "presenter.rb", presenter_path
  end

  def create_presenter_test_file
    template "presenter_rspec.rb", presenter_rspec_path
  end

  private

  def target_list
    target_names.join(", ")
  end

  def target_names
    targets.map { |t| ":#{t}" }
  end

  def normalized_class_name
    class_name.split("::").map { |part| part.chomp("Presenter") }.join("::")
  end

  def normalized_file_name
    file_name.split("/").map { |part| part.chomp("_presenter").underscore }.join("/")
  end

  def presenter_path
    File.join("app/presenters", class_path, "#{normalized_file_name}_presenter.rb")
  end

  def presenter_rspec_path
    File.join("spec/presenters", class_path, "#{normalized_file_name}_presenter_spec.rb")
  end
end
