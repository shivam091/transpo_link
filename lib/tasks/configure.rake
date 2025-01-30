# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# rake transpo_link:configure RAILS_ENV=XXX
# rake transpo_link:unconfigure! RAILS_ENV=XXX

require File.dirname(__FILE__) + "/rake_helper.rb"

namespace :transpo_link do

  desc "Configure TranspoLink on new system"
  task configure: :environment do
    Kernel.warn ERB.new(<<~EOS).result
      **********************************************************************************************
      **********************************************************************************************
        ████████ ██████   █████  ███    ██ ██████ ██████   ██████     ██      ██ ███    ██ ██   ██ 
           ██    ██   ██ ██   ██ ████   ██ ██     ██   ██ ██    ██    ██      ██ ████   ██ ██  ██  
           ██    ██████  ███████ ██ ██  ██ ██████ ██████  ██    ██    ██      ██ ██ ██  ██ █████  
           ██    ██   ██ ██   ██ ██  ██ ██     ██ ██      ██    ██    ██      ██ ██  ██ ██ ██  ██ 
           ██    ██   ██ ██   ██ ██   ████ ██████ ██       ██████     ███████ ██ ██   ████ ██   ██ 
      **********************************************************************************************
      **********************************************************************************************
    EOS
    answer = prompt("You are about to configure the TranspoLink in #{Rails.env} " \
      "environment. Do you want to proceed? (Yn): ", %w{Y n})
    if answer == "Y"
      puts "↳ Installing TranspoLink"
      begin
        sh "bundle install"
        Rake::Task["tmp:create"].invoke
        Rake::Task["db:create"].invoke
        Rake::Task["db:migrate"].invoke
        Rake::Task["db:seed"].invoke
        Rake::Task["transpo_link:db:seed"].invoke
        Rake::Task["assets:precompile"].invoke
        sh "rspec"
        puts "↳ Installation completed"
      rescue Exception => e
        raise "↳ Installation aborted due to internal errors!"
      end
    else
      puts "↳ Installation cancelled."
    end
  end

  desc "Unconfigure TranspoLink from the system"
  task unconfigure!: :environment do
    Kernel.warn ERB.new(<<~EOS).result
      ************************************************************
      ************************************************************
        ██     ██  █████  ██████  ███    ██ ██ ███    ██  ██████ 
        ██     ██ ██   ██ ██   ██ ████   ██ ██ ████   ██ ██      
        ██  █  ██ ███████ ██████  ██ ██  ██ ██ ██ ██  ██ ██   ███ 
        ██ ███ ██ ██   ██ ██   ██ ██  ██ ██ ██ ██  ██ ██ ██    ██ 
         ███ ███  ██   ██ ██   ██ ██   ████ ██ ██   ████  ██████  
      ************************************************************
      ************************************************************
    EOS
    answer = prompt("You are about to unconfigure the TranspoLink in " \
      "#{Rails.env} environment. This action can not be UNDONE. Do you still " \
      "want to proceed? (Yn): ", %w{Y n})
    if answer == "Y"
      puts "↳ Uninstalling TranspoLink"
      begin
        Rake::Task["assets:clobber"].invoke
        Rake::Task["db:drop"].invoke
        Rake::Task["log:clear"].invoke
        Rake::Task["tmp:clear"].invoke
        puts "↳ Uninstallation completed"
      rescue Exception => e
        raise "↳ Uninstallation aborted due to internal errors!"
      end
    else
      puts "↳ Uninstallation cancelled."
    end
  end
end
