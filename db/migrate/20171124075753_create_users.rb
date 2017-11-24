class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :chat_room
      t.string :user_key

      t.timestamps null: false
    end
  end
end
