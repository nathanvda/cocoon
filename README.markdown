# cocoon

[![Build Status](http://travis-ci.org/nathanvda/cocoon.png)](http://travis-ci.org/nathanvda/cocoon)

cocoon is a Rails3 gem to allow easier handling of nested forms.

Nested forms are forms that handle nested models and attributes in one form.
For example a project with its tasks, an invoice with its ordered items.

It is formbuilder-agnostic, so it works with standard Rails, or Formtastic or simple_form.

## Prerequisites

This gem uses jQuery, it is most useful to use this gem in a rails3
project where you are already using jQuery.

Furthermore i would advice you to use either formtastic or simple_form.

I have a sample project where I demonstrate the use of cocoon with formtastic.

## Installation

Inside your `Gemfile` add the following:

````ruby
gem "cocoon"
````

### Rails 3.1

Add the following to `application.js` so it compiles to the
asset_pipeline

````ruby
//= require cocoon
````

### Rails 3.x

If you are using Rails 3.0.x, you need to run the installation task (since rails 3.1 this is no longer needed):

````ruby
rails g cocoon:install
````

This will install the needed javascript file.
Inside your `application.html.haml` you will need to add below the default javascripts:

````haml
= javascript_include_tag :cocoon
````

or using erb, you write

````ruby
<%= javascript_include_tag :cocoon %>
````

That is all you need to do to start using it!

## Usage

Suppose you have a model `Project`:

````ruby
rails g scaffold Project name:string description:string
````

and a project has many `tasks`:

````ruby
rails g model Task description:string done:boolean project_id:integer
````

Edit the models to code the relation:

````ruby
class Project < ActiveRecord::Base
  has_many :tasks
  accepts_nested_attributes_for :tasks, :reject_if => :all_blank, :allow_destroy => true
end

class Task < ActiveRecord::Base
  belongs_to :project
end
````

What we want to achieve is to get a form where we can add and remove the tasks dynamically.
What we need for this, is that the fields for a new/existing `task` are defined in a partial
view called `_task_fields.html`.

We will show the sample usage with the different possible form-builders.

### Using formtastic

Inside our `projects/_form` partial we then write:

````haml
- f.inputs do
  = f.input :name
  = f.input :description
  %h3 Tasks
  #tasks
    = f.semantic_fields_for :tasks do |task|
      = render 'task_fields', :f => task
    .links
      = link_to_add_association 'add task', f, :tasks
  -f.actions do
    = f.action :submit
````

and inside the `_task_fields` partial we write:

````haml
.nested-fields
  = f.inputs do
    = f.input :description
    = f.input :done, :as => :boolean
    = link_to_remove_association "remove task", f
````

That is all there is to it!

There is an example project on github implementing it called [cocoon_formtastic_demo](https://github.com/nathanvda/cocoon_formtastic_demo).

### Using simple_form

This is almost identical to formtastic, instead of writing `semantic_fields_for` you write `simple_fields_for`.

There is an example project on github implementing it called [cocoon_simple_form_demo](https://github.com/nathanvda/cocoon_simple_form_demo).


### Using standard rails forms

I will provide a full example (and a sample project) later.

## How it works

I define two helper functions:

### link_to_add_association

This function will add a link to your markup that will, when clicked, dynamically add a new partial form for the given association.
This should be placed below the `semantic_fields_for`.

It takes four parameters:

- name: the text to show in the link
- f: referring to the containing form-object
- association: the name of the association (plural) of which a new instance needs to be added (symbol or string).
- html_options: extra html-options (see `link_to`)
  There are some special options, the first three allow to control the placement of the new link-data:
  - `data-association-insertion-node` : the jquery selector of the node
  - `data-association-insertion-method` : jquery method that inserts the new data. `before`, `after`, `append`, `prepend`, etc. Default: `before`
  - `data-association-insertion-position` : old method specifying where to insert new data.
      - this setting still works but `data-association-insertion-method` takes precedence. may be removed in a future version.
  - `partial`: explicitly declare the name of the partial that will be used
  - `render_options` : options passed through to the form-builder function (e.g. `simple_fields_for`, `semantic_fields_for` or `fields_for`).
                       If it contains a `:locals` option containing a hash, that is handed to the partial.

Optionally you could also leave out the name and supply a block that is captured to give the name (if you want to do something more complicated).

#### :render_options
Inside the `html_options` you can add an option `:render_options`, and the containing hash will be handed down to the form-builder for the inserted
form. E.g. especially when using `twitter-bootstrap` and `simple_form` together, the `simple_fields_for` needs the option `:wrapper => 'inline'` which can
be handed down as follows:

````haml
= link_to_add_association 'add something', f, :something, :render_options => {:wrapper => 'inline' }
````

If you want to specify locals that needed to handed down to the partial, write

````haml
= link_to_add_association 'add something', f, :something, :render_options => {:locals => {:sherlock => 'Holmes' }}
````


#### :partial

To overrule the default partial name, e.g. because it shared between multiple views, write

````haml
= link_to_add_association 'add something', f, :something, :partial => 'shared/something_fields'
````


### link_to_remove_association

This function will add a link to your markup that will, when clicked, dynamically remove the surrounding partial form.
This should be placed inside the partial `_<association-object-singular>_fields`.

It takes three parameters:

- name: the text to show in the link
- f: referring to the containing form-object
- html_options: extra html-options (see `link_to`)

Optionally you could also leave out the name and supply a block that is captured to give the name (if you want to do something more complicated).


### Callbacks (upon insert and remove of items)

There is an option to add a callback on insertion or removal. If in your view you have the following snippet to select an `owner`
(we use slim for demonstration purposes)

````haml
#owner
  #owner_from_list
    = f.association :owner, :collection => Person.all(:order => 'name'), :prompt => 'Choose an existing owner'
  = link_to_add_association 'add a new person as owner', f, :owner
````

This view part will either let you select an owner from the list of persons, or show the fields to add a new person as owner.


The callbacks can be added as follows:

````javascript
$(document).ready(function() {
    $('#owner').bind('insertion-callback',
         function() {
           $("#owner_from_list").hide();
           $("#owner a.add_fields").hide();
         });
    $('#owner').bind("removal-callback",
         function() {
           $("#owner_from_list").show();
           $("#owner a.add_fields").show();
         });
    $('#owner').bind("after-removal-callback",
         function() {
           /* e.g. recalculate order of child items */
         });
});
````

Do note that for the callbacks to work there has to be a surrounding container (div), where you can bind the callbacks to.
Note that the default `removal-callback` is called _before_ removing the nested item.

### Control the Insertion behaviour

The default insertion location is at the back of the current container. But we have added two `data`-attributes that are read to determine the insertion-node and -method.

For example:

````javascript
$(document).ready(function() {
    $("#owner a.add_fields").
      data("association-insertion-method", 'before').
      data("association-insertion-node", 'this');
});
````

The `association-insertion-node` will determine where to add it. You can choose any selector here, or specify this (default it is the parent-container).

The `association-insertion-method` will determine where to add it in relation with the node. Any jQuery DOM Manipulation method can be set but we recommend sticking to any of the following: `before`, `after`, `append`, `prepend`. It is unknown at this time what others would do.


### Partial

If no explicit partial-name is given, `cocoon` looks for a file named `_<association-object_singular>_fields`.
To override the default partial-name use the option `:partial`.

For the javascript to behave correctly, the partial should start with a container (e.g. `div`) of class `.nested-fields`.



There is no limit to the amount of nesting, though.


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


## Todo

* add more sample relations: `has_many :through`, `belongs_to`, ...
* improve the tests (test the javascript too)(if anybody wants to lend a hand ...?)

## Copyright

Copyright (c) 2010 Nathan Van der Auwera. See LICENSE for details.
