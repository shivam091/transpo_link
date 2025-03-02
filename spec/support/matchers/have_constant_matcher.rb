RSpec::Matchers.define :have_constant do |expected_constant|
  chain :with_value do |expected_value|
    @expected_value = expected_value
  end

  match do |owner|
    klass_or_module = (owner.is_a?(Class) || owner.is_a?(Module)) ? owner : owner.class
    constant_defined = klass_or_module.const_defined?(expected_constant)

    if @expected_value.nil?
      constant_defined
    else
      constant_defined && klass_or_module.const_get(expected_constant) == @expected_value
    end
  end

  description do
    desc = "define the #{expected_constant} constant"
    desc += " with value #{@expected_value.inspect}" if @expected_value
    desc
  end

  failure_message do |owner|
    klass_or_module = (owner.is_a?(Class) || owner.is_a?(Module)) ? owner : owner.class

    if klass_or_module.const_defined?(expected_constant)
      actual_value = klass_or_module.const_get(expected_constant)
      "expected #{klass_or_module} to have constant #{expected_constant} with value #{@expected_value.inspect}, but it was #{actual_value.inspect}"
    else
      "expected #{klass_or_module} to have constant #{expected_constant}"
    end
  end

  failure_message_when_negated do |owner|
    klass_or_module = (owner.is_a?(Class) || owner.is_a?(Module)) ? owner : owner.class

    if klass_or_module.const_defined?(expected_constant) && (!@expected_value || klass_or_module.const_get(expected_constant) == @expected_value)
      "expected #{klass_or_module} not to have constant #{expected_constant}#{@expected_value ? " with value #{@expected_value.inspect}" : ''}"
    else
      "expected #{klass_or_module} not to have constant #{expected_constant}"
    end
  end
end
