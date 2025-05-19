# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# rake transpo_link:db:add_permissions RAILS_ENV=XXX

desc "Seeds access control permissions"
namespace :transpo_link do
  namespace :db do
    task add_permissions: :environment do
      if ENV["RESET"] == "true"
        puts "↳ Resetting access control data..."

        AccessControl::RolePermission.destroy_all
        AccessControl::Permission.destroy_all
        AccessControl::Action.destroy_all
        AccessControl::Module.destroy_all

        puts "↳ Access control tables reset."
      end

      permissions_data = YAML.load_file(Rails.root.join("config", "access_control", "permissions.yaml"))["permissions"]
      raise "Invalid YAML format" unless permissions_data.is_a?(Hash)

      puts "↳ Adding modules, actions, and permissions..."

      permissions_data.with_indifferent_access.each.with_index(1) do |(module_key, actions), module_index|
        mdule = AccessControl::Module.safe_find_or_create_by!(label_key: module_key) do |mdule|
          mdule.position = module_index
          mdule.is_active = true
        end

        actions.each.with_index(1) do |action_key, action_index|
          action = AccessControl::Action.safe_find_or_create_by!(label_key: action_key) do |action|
            action.is_active = true
          end

          AccessControl::Permission.safe_find_or_create_by!(action: action, module: mdule) do |permission|
            permission.position = action_index
            permission.is_active = true
          end
        end
      end

      puts "↳ Assigning permissions to all roles..."

      Role.find_each do |role|
        AccessControl::Permission.find_each do |permission|
          AccessControl::RolePermission.safe_find_or_create_by!(
            role: role,
            permission: permission
          )
        end
      end

      puts "↳ Added permissions and assigned to all roles."
    end
  end
end
