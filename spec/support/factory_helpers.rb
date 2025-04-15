# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module FactoryHelpers
  def find_or_create_role(name, traits = [])
    Role.find_by(name: name) || create("#{name}_role".to_sym, *traits)
  end

  def find_or_create_unit(symbol, traits = [])
    Unit.find_by(symbol: symbol) || create("#{symbol}_unit".to_sym, *traits)
  end
end

FactoryBot::SyntaxRunner.include FactoryHelpers
