class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables do |t|
      t.integer :capacity
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
