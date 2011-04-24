class Post < ActiveRecord::Base
  has_many :comments
  has_many :people
end
