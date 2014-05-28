class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :adress
      t.integer :port

      t.timestamps
    end
  end
end
