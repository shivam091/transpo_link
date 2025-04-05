# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# This class provides a mechanism to automatically locate and require migration files
# in Rails applications. It allows dynamically requiring migration files in specs
# without explicitly specifying the full migration filename.
#
# @example
#   require_migration!
#   require_migration! "create_roles"
#
class RequireMigration
  ##
  # Custom error class for handling migration file loading errors.
  #
  class AutoLoadError < RuntimeError
    MESSAGE = "Could not find a migration file for `%{file_name}`!\n" \
              "You may need to specify the migration file name manually."

    ##
    # Initializes the AutoLoadError with a descriptive message.
    #
    # @param file_name [String] The migration file name that was not found.
    #
    def initialize(file_name)
      super(format(MESSAGE, file_name: file_name))
    end
  end

  # Directories where migrations are expected to be found.
  MIGRATION_FOLDERS = %w[db/migrate].freeze

  # Regex pattern to extract the migration file name from a spec file path.
  SPEC_FILE_PATTERN = %r{.+/(?:\d+_)?(?<file_name>.+)_spec\.rb}

  class << self
    ##
    # Attempts to require a migration file based on the given name.
    #
    # @param file_name [String] The name of the migration file (without timestamp).
    # @raise [AutoLoadError] If no matching migration file is found.
    #
    def require_migration!(file_name)
      file_path = search_migration_file(file_name).first
      raise AutoLoadError, file_name unless file_path

      require file_path
    end

    private

    ##
    # Searches for a migration file that matches the given name.
    #
    # @param file_name [String] The migration name without timestamp.
    # @return [Array<String>] A list of matching migration file paths.
    #
    def search_migration_file(file_name)
      # Regex pattern to match migration filenames (e.g., "20250130103139_create_roles.rb").
      pattern = %r{\d+_#{file_name}\.rb}

      MIGRATION_FOLDERS.flat_map do |path|
        Dir["#{Rails.root.join(path)}/*.rb"].select { |m| pattern.match?(File.basename(m)) }
      end
    end
  end
end

##
# This method attempts to require the corresponding migration file for the calling spec.
# If no filename is provided, it automatically extracts the migration name from the spec filename.
#
# @param file_name [String, nil] The name of the migration file (without timestamp).
# @raise [RequireMigration::AutoLoadError] If no matching migration file is found.
#
# Usage Example:
#   require_migration!  # Automatically detects the migration from the spec filename.
#   require_migration!("create_users")  # Explicitly loads "db/migrate/xxxx_create_users.rb".
#
def require_migration!(file_name = nil)
  file_name ||= caller_locations.first.path.match(RequireMigration::SPEC_FILE_PATTERN)[:file_name]
  RequireMigration.require_migration!(file_name)
end
