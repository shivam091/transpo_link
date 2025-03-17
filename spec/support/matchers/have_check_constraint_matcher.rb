# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts that the check constraint exists.
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { is_expected.to have_check_constraint(:constraint_name) }
#   it { is_expected.to have_check_constraint(:constraint_name).with_expression("expression") }
# end
# ```
RSpec::Matchers.define :have_check_constraint do |constraint_name|
  chain :with_expression do |expression|
    @expression = expression
  end

  match do |record|
    @table_name = record.class.table_name.to_s
    @constraint_name = constraint_name.to_s
    check_constraints = connection.check_constraints(@table_name)

    check_constraints.any? do |check_constraint|
      check_constraint.name == @constraint_name &&
        check_constraint.table_name == @table_name &&
        (@expression.nil? || check_constraint.expression.eql?(@expression))
    end
  end

  description do
    desc = "have a check constraint named '#{@constraint_name}' on table '#{@table_name}'"
    desc += " with expression '#{@expression}'" if @expression
    desc
  end

  failure_message do
    msg = "expected '#{@table_name}' to have a check constraint named '#{@constraint_name}'"
    msg += " with expression '#{@expression}'" if @expression
    msg
  end

  failure_message_when_negated do
    msg = "expected '#{@table_name}' to not have a check constraint named '#{@constraint_name}'"
    msg += " with expression '#{@expression}'" if @expression
    msg
  end
end
