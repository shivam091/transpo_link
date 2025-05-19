# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module AuthorizationHelpers
  # Stubs authorization across the app
  def stub_authorization!(user = nil, always_allow: true)
    ability = instance_double("Ability")

    allow(Ability).to receive(:new).with(user) { ability }

    if always_allow
      allow(ability).to receive(:authorize!) { true }
    else
      allow(ability).to receive(:authorize!).and_raise(AccessDeniedError)
    end

    ability
  end

  # Grants the user a specific permission (module/action key pair)
  #
  # @param user [User] The user to grant the permission to
  # @param module_key [String] The module identifier (e.g., "tax_rates")
  # @param action_key [String] The action identifier (e.g., "create")
  #
  def grant_permission!(user, module_key, action_key)
    role = user.role

    m_key = module_key.to_s
    a_key = action_key.to_s

    mod = AccessControl::Module.find_by(label_key: m_key) || create(:module, label_key: m_key)
    act = AccessControl::Action.find_by(label_key: a_key) || create(:action, label_key: a_key)

    permission = AccessControl::Permission.find_by(module: mod, action: act) || create(:permission, module: mod, action: act)
    AccessControl::RolePermission.find_by(permission:, role:) || create(:role_permission, permission:, role:)
  end
end
