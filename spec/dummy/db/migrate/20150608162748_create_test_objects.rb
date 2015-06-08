class CreateTestObjects < ActiveRecord::Migration
  def change
    create_table :test_objects do |t|
      t.string :name
    end
  end
end
