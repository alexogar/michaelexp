# -*- encoding : utf-8 -*-
class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|

      t.timestamps
    end
  end
end
