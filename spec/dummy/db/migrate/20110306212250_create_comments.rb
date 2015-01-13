class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :body
      t.string :author
      t.integer :post_id

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :comments
  end
end
