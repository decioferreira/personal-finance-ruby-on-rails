class CreateMonthlyIncomes < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_incomes do |t|
      t.date :month, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :monthly_incomes, "amount >= 0", name: "monthly_incomes_amount_non_negative"
    add_index :monthly_incomes, [ :user_id, :month ], unique: true
  end
end
