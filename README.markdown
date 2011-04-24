# cocoon

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

    gem "cocoon"

Run the installation task:

    rails g cocoon:install

This will install the needed javascript file.
Inside your `application.html.haml` you will need to add below the default javascripts:

    = javascript_include_tag :cocoon

or using erb, you write

    <%= javascript_include_tag :cocoon %>

That is all you need to do to start using it!

## Usage

Suppose you have a model `Project`:

    rails g scaffold Project name:string description:string

and a project has many `tasks`:

    rails g model Task description:string done:boolean project_id:integer

Edit the models to code the relation:

    class Project < ActiveRecord::Base
      has_many :tasks
      accepts_nested_attributes_for :tasks
    end

    class Task < ActiveRecord::Base
      belongs_to :project
    end

What we want to achieve is to get a form where we can add and remove the tasks dynamically.
What we need for this, is that the fields for a new/existing `task` are defined in a partial
view called `_task_fields.html`.

We will show the sample usage with the different possible form-builders.

### Using formtastic

Inside our `projects/_form` partial we then write:

    - f.inputs do
      = f.input :name
      = f.input :description
      %h3 Tasks
      #tasks
        = f.semantic_fields_for :tasks do |task|
          = render 'task_fields', :f => task
        .links
          = link_to_add_association 'add task', f, :tasks
      -f.buttons do
        = f.submit 'Save'

and inside the `_task_fields` partial we write:

    .nested-fields
      = f.inputs do
        = f.input :description
        = f.input :done, :as => :boolean
        = link_to_remove_association "remove task", f

That is all there is to it!

There is an example project on github implementing it called [formtastic-cocoon-demo](https://github.com/nathanvda/formtastic-cocoon-demo).

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
  There are two extra options that allow to conrol the placement of the new link-data:
  - `data-association-insertion-node` : the jquery selector of the node
  - `data-association-insertion-position` : insert the new data `before` or `after` the given node.

Optionally you could also leave out the name and supply a block that is captured to give the name (if you want to do something more complicated).

There is an option to add a callback on insertion. The callback can be added as follows:

    $("#todo_tasks a.add_fields").
      data("insertion-callback",
         function() {
           $(this).find("textarea").autoResize({extraSpace:0}).change();
         });


### link_to_remove_association

This function will add a link to your markup that will, when clicked, dynamically remove the surrounding partial form.
This should be placed inside the partial `_<association-object-singular>_fields`.

It takes three parameters:

- name: the text to show in the link
- f: referring to the containing form-object
- html_options: extra html-options (see `link_to`)

Optionally you could also leave out the name and supply a block that is captured to give the name (if you want to do something more complicated).

### Partial

The partial should be named `_<association-object_singular>_fields`, and should start with a div of class `.nested-fields`.

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

* add more sample relations: has_many :through, belongs_to, ...
* improve the tests (test the javascript too)(if anybody wants to lend a hand ...?)

## Copyright

Copyright (c) 2010 Nathan Van der Auwera. See LICENSE for details.
