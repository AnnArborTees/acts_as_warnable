class CreateWarnings < ActiveRecord::Migration
  def change
    create_table :warnings do |t|
      t.integer :warnable_id
      t.string :warnable_type
      t.text :message
    end
  end
end
