class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens, if_not_exists: true do |t|
      t.references :user, foreign_key: true, index: true
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
