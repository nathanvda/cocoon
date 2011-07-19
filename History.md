# Change History / Release Notes

## Version 1.0.6 (19/06/2011)

* The javascript has been improved to consistently use `e.preventDefault` instead of returning false.

Run

    rails g cocoon:install

to copy the new `cocoon.js` to your `public/javascripts` folder.


## Version 1.0.5 (17/06/2011)

* This release make sure that the `link_to_add_association` generates a correctly clickable
  link in the newer rails 3 versions as well. In rails 3.0.8. the html was double escaped.

If you are upgrading from 1.0.4, you just have to update the gem. No other actions needed. If you are updating
from earlier versions, it is safer to do

    rails g cocoon:install

This will copy the new `cocoon.js` files to your `public/javascripts` folder.


