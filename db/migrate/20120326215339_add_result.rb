# -*- encoding : utf-8 -*-
class AddResult < ActiveRecord::Migration
  def change
    add_column :users, :result, :text
  end
end
