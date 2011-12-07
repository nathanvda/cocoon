# Change History / Release Notes

## Version 1.0.15

* added `data-association-insertion-method` that gives more control over where to insert the new nested fields.
  It takes a jquery method as parameter that inserts the new data. `before`, `after`, `append`, `prepend`, etc. Default: `before`.
* `data-association-insertion-position` is still available and acts as an alias. Probably this will be deprecated in the future.


## Version 1.0.14

* When playing with `simple_form` and `twitter-bootstrap`, I noticed it is crucial that I call the correct nested-fields function.
  That is: `fields_for` for standard forms, `semantic_fields_for` in formtastic and `simple_fields_for` for simple_form.
  Secondly, this was not enough, I needed to be able to hand down options to that method. So in the `link_to_add_association` method you
  can now an extra option `:render_options` and that hash will be handed to the association-builder.

  This allows the nested fields to be built correctly with `simple_form` for `twitter-bootstrap`.

## Version 1.0.13

* A while ago we added the option to add a javascript callback on inserting a new associated object, I now made sure we can add a callback on insertion
  and on removal of a new item. One example where this was useful for me is visible in the demo project `cocoon_simple_form_demo` where I implemented a
  `belongs_to` relation, and either select from a list, or add a new element.
  So: the callback-mechanism has changed, and now the callback is bound to the parent container, instead of the link itself. This is because we can also
  bind the removal callback there (as the removal link is inserted in the html dynamically).

  For more info, see the `README`.

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


