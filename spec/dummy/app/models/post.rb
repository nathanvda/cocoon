class Post < ActiveRecord::Base
  has_many :comments
  has_many :admin_comments, class_name: "Comment", :conditions => { :author => "Admin" }
  has_many :people
end
