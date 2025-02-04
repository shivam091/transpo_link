# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"
require "generators/service/service_generator"

RSpec.describe ServiceGenerator, type: :generator do
  destination test_directory_path
  arguments %w[Mailer::EmailService send_email notify_user]

  before(:all) do
    run_generator
  end

  it "creates a service file with correct path and name" do
    expect(File).to exist(File.join(destination_root, "app/services/mailer/email_service.rb"))
  end

  it "creates an RSpec test file for the service" do
    expect(File).to exist(File.join(destination_root, "spec/services/mailer/email_service_spec.rb"))
  end

  it "ensures generated service class does not append 'Service' if already included" do
    content = File.read(File.join(destination_root, "app/services/mailer/email_service.rb"))
    expect(content).to match(/class Mailer::EmailService < ApplicationService/)
  end

  it "includes the specified method names inside the service class" do
    content = File.read(File.join(destination_root, "app/services/mailer/email_service.rb"))
    expect(content).to include("def send_email")
    expect(content).to include("def notify_user")
  end

  it "creates a valid service test file" do
    content = File.read(File.join(destination_root, "spec/services/mailer/email_service_spec.rb"))
    expect(content).to include("RSpec.describe Mailer::EmailService")
  end
end
