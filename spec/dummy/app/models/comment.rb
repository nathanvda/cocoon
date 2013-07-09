class Comment < ActiveRecord::Base
  belongs_to :post

  unless Rails.rails4?
    attr_protected :author
  end
end
