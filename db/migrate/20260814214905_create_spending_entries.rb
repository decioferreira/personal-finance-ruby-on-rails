class CreateSpendingEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :spending_entries do |t|
      t.date :date, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :description, null: false
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end

    add_check_constraint :spending_entries, "amount > 0", name: "spending_entries_amount_positive"

    # Speeds up "spending for month X" queries, the core access pattern of the dashboard.
    add_index :spending_entries, [ :user_id, :date ]
  end
end
