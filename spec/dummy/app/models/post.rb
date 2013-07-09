class Post < ActiveRecord::Base
  has_many :comments
  if Rails.rails4?
    has_many :admin_comments, -> { where author: "Admin" }, :class_name => "Comment"
  else
    has_many :admin_comments, :class_name => "Comment", :conditions => { :author => "Admin" }
  end
  has_many :people
end
