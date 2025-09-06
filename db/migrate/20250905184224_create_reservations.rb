class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :table, null: false, foreign_key: true
      t.integer :party_size, null: false
      t.decimal :duration, precision: 10, scale: 2, null: false
      t.datetime :start_time, null: false
      t.tsrange :period, null: false
      t.string :idempotency_key

      t.timestamps
    end

    enable_extension "btree_gist"

    add_exclusion_constraint :reservations,
      "table_id WITH =, period WITH &&",
      using: :gist,
      name: "no_table_period_overlap"
    add_index :reservations, %i[table_id period]
    add_index :reservations, :idempotency_key, unique: true
  end
end
