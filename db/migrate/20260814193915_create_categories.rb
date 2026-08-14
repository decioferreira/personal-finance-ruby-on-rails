class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Case-insensitive uniqueness per user, enforced at the DB level
    # (matches the case-insensitive uniqueness validation on Category).
    add_index :categories, "user_id, LOWER(name)", unique: true, name: "index_categories_on_user_id_and_lower_name"
  end
end
