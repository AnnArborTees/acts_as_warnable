class CreateWarnings < ActiveRecord::Migration
  def change
    create_table :warnings do |t|
      t.integer :warnable_id
      t.string :warnable_type
      t.text :message
      t.datetime :dismissed_at
      t.integer :dismisser_id
    end
  end
end
