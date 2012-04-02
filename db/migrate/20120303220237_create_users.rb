# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, :limit =>20
      t.integer :age, :max => 100
      t.string :sex, :limit => 20
      t.timestamps
    end
  end
end
