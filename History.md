# Change History / Release Notes

## Version 1.0.12

* using "this" in `association-insertion-node` is now possible

If you are using rails < 3.1, you should run

    rails g cocoon:install

to install the new `cocoon.js` to your `public/javascripts` folder.

## Version 1.0.11


## Version 1.0.10

* Fuck! Built the gem with 1.9.2 again. Built the gem again with 1.8.7.

## Version 1.0.9

* is now rails 3.1 compatible. If you are not using Rails 3.1 yet, this should have no effect.
  For rails 3.1 the cocoon.js no longer needs to be installed using the `rails g cocoon:install`. It is
  automatically used from the gem.

## Version 1.0.8

* Loosened the gem dependencies.

## Version 1.0.7 (20/06/2011)

Apparently, the gem 1.0.6 which was generated with ruby 1.9.2 gave the following error upon install:

      uninitialized constant Psych::Syck (NameError)

This is related to this bug: http://rubyforge.org/tracker/?group_id=126&atid=575&func=detail&aid=29163

This should be fixed in the next release of rubygems, the fix should be to build the gem with ruby 1.8.7.
Let's hope this works.

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


