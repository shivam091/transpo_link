# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_feedbacks_user_id_on_users,
                     on_delete: :nullify
                   },
                   null: false,
                   index: {using: :btree}
      t.references :reviewable,
                   type: :uuid,
                   polymorphic: true,
                   null: false,
                   index: {using: :btree}
      t.decimal :rating, precision: 3, scale: 1
      t.text :comment
      t.boolean :is_unread, default: true, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "rating IS NOT NULL", name: :check_feedbacks_rating_presence
      t.check_constraint "rating >= 0.0 AND rating <= 10.0", name: :check_feedbacks_rating_numericality
      t.check_constraint "rating * 2 = FLOOR(rating * 2)", name: :check_feedbacks_rating_step

      t.check_constraint "comment IS NOT NULL AND comment <> ''", name: :check_feedbacks_comment_presence
      t.check_constraint "CHAR_LENGTH(comment) <= 1000 AND CHAR_LENGTH(comment) > 0", name: :check_feedbacks_comment_length
    end
  end
end
