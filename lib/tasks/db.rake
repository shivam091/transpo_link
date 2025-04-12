# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# rake transpo_link:db:seed RAILS_ENV=XXX

namespace :transpo_link do
  namespace :db do
    desc "Seeds the database with default data"
    task seed: :environment do
      begin
        Rake::Task["transpo_link:db:add_unit_conversions"].invoke

        puts "↳ Database seeding completed"
      rescue Exception => e
        raise "↳ Database seeding is aborted due to internal errors!"
      end
    end
  end
end
