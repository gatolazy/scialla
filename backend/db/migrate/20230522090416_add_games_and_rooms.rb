class AddGamesAndRooms < ActiveRecord::Migration[ 7.0 ]

  def change

    # Add total games' data to the users:
    change_table :users do |t|
      t.bigint :total_activities, default: 0
      t.bigint :total_score, default: 0
    end

    # Activities:
    create_table :activities do |t|
      t.string :name, null: false
      t.string :description
      t.integer :min_players
      t.integer :max_players
      t.timestamps

      t.index :name, unique: true
    end

    # Rooms:
    create_table :rooms do |t|
      t.integer :activity_id
      t.timestamps
    end

    # Link rooms to users:
    create_join_table :users, :rooms, table_name: :scores do |t|
      t.primary_key :sid, :string
      t.integer :score, default: 0
    end

    # Temporary poc only table:
    create_table :questions do |t|
      t.string :text
    end

  end

end

