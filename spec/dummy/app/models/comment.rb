class Comment < ActiveRecord::Base
  belongs_to :post

  attr_protected :author
end
