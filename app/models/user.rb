# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  validates :name, :age, :sex, :presence => true
end
