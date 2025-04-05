# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateRequestLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :request_logs, id: :uuid do |t|
      t.string :uuid, index: {unique: true, using: :btree}
      t.string :uri
      t.string :method
      t.jsonb :query_params, default: "{}", index: {using: :gin}
      t.string :session_id, index: {using: :btree}
      t.string :session_private_id
      t.inet :remote_address, index: {using: :btree}
      t.string :user_agent
      t.string :referrer
      t.string :origin
      t.bigint :memory_usage, default: 0
      t.decimal :cpu_usage, precision: 5, scale: 2, default: 0.0
      t.jsonb :ip_info, default: "{}", index: {using: :gin}
      t.jsonb :request_headers, default: "{}", index: {using: :gin}
      t.jsonb :response_headers, default: "{}", index: {using: :gin}
      t.integer :status
      t.integer :response_size
      t.jsonb :exception, default: "{}", index: {using: :gin}
      t.decimal :elapsed_time, precision: 10, scale: 4, default: 0.0
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_request_logs_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: true,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "uuid IS NOT NULL AND uuid <> ''", name: :check_request_logs_uuid_presence
      t.check_constraint "uri IS NOT NULL AND uri <> ''", name: :check_request_logs_uri_presence
      t.check_constraint "method IS NOT NULL AND method <> ''", name: :check_request_logs_method_presence
      t.check_constraint "remote_address IS NOT NULL", name: :check_request_logs_remote_address_presence
      t.check_constraint "ip_info IS NOT NULL", name: :check_request_logs_ip_info_presence
      t.check_constraint "UPPER(method) = method", name: :check_request_logs_method_in_uppercase
    end
  end
end
