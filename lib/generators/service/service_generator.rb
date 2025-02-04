# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "rails/generators"

class ServiceGenerator < Rails::Generators::NamedBase
  desc "This generator creates a service in app/services."

  source_root File.expand_path("../templates", __FILE__)

  argument :methods, type: :array, default: []

  check_class_collision suffix: "Service"

  def create_service_file
    template "service.rb", service_path
  end

  def create_service_test_file
    template "rspec.rb", rspec_path
  end

  private

  def normalized_class_name
    class_name.split("::").map { |part| part.chomp("Service") }.join("::")
  end

  def normalized_file_name
    file_name.split("/").map { |part| part.chomp("_service").underscore }.join("/")
  end

  def service_path
    File.join("app/services", class_path, "#{normalized_file_name}_service.rb")
  end

  def rspec_path
    File.join("spec/services", class_path, "#{normalized_file_name}_service_spec.rb")
  end
end
