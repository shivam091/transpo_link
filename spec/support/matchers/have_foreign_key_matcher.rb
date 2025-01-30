# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts that the foreign key exists.
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { is_expected.to have_foreign_key(:role_id) }
#   it { is_expected.to have_foreign_key(:role_id).with_name(:fk_users_role_id_on_roles) }
#   it { is_expected.to have_foreign_key(:role_id).on_delete(:restrict) }
#   it { is_expected.to have_foreign_key(:role_id).with_name(:fk_users_role_id_on_roles).on_delete(:restrict) }
# end
# ```
RSpec::Matchers.define :have_foreign_key do |column_name|
  chain :with_name do |identifier|
    @identifier = identifier
  end

  chain :on_delete do |on_delete|
    @on_delete = on_delete
  end

  match do |model|
    foreign_key = model.class.connection.foreign_keys(model.class.table_name).find do |foreign_key|
      foreign_key.column == column_name.to_s
    end
    return false unless foreign_key

    @options = foreign_key&.options

    matches_identifier? && matches_on_delete?
  end

  description do
    build_message("have a foreign key on #{column_name}")
  end

  failure_message do
    build_message("expected to have a foreign key on #{column_name}")
  end

  failure_message_when_negated do
    build_message("expected not to have a foreign key on #{column_name}")
  end

  private

  def matches_identifier?
    @identifier.nil? || (@options[:name] == @identifier.to_s)
  end

  def matches_on_delete?
    @on_delete.nil? || (@options[:on_delete] == @on_delete)
  end

  def build_message(base_message)
    details = []
    details << "with name #{@identifier}" if @identifier
    details << "on_delete => #{@on_delete}" if @on_delete
    details.empty? ? base_message : "#{base_message} #{details.join(' ')}"
  end
end
