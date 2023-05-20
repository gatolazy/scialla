class CreateUsers < ActiveRecord::Migration[ 7.0 ]

  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :display_name
      t.string :department
      t.string :identifier, limit: 32
      t.string :password_digest, null: false
      t.timestamp :last_login_at
      t.timestamps

      t.index :username, unique: true
    end
  end

end

