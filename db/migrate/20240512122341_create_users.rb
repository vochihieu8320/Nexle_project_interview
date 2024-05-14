class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, if_not_exists: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, index: { unique: true }
      t.string :password

      t.timestamps
    end
  end
end
