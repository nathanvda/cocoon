# formtastic-cocoon

Formtastic-cocoon is a Rails3 gem, extending formtastic, to allow easier handling of nested forms.

Nested forms are forms that handle nested models and attributes in one form.
For example a project with its tasks, an invoice with its ordered items.

## Prerequisites

As this gem extends formtastic and uses jQuery, it is only useful to use this gem in a rails3
project where you are already using formtastic and jQuery.

I have a sample project where I demonstrate both.

## Installation

Inside your `Gemfile` add the following:

    gem "formtastic_cocoon"

Run the installation task:

    rails g formtastic_cocoon:install

This will install the needed javascript file.
Inside your `application.html.haml` you will need to add below the default javascripts:

    = javascript_include_tag :formtastic_cocoon

or using erb, you write

    <%= javascript_include_tag :formtastic_cocoon %>

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

## How it works

I define two helper functions:

### link_to_add_association

This function will add a link to your markup that will, when clicked, dynamically add a new partial form for the given association.
This should be placed below the `semantic_fields_for`.

It takes three parameters:

- name: the text to show in the link
- f: referring to the containing formtastic form-object
- association: the name of the association (plural) of which a new instance needs to be added (symbol or string).

### link_to_remove_association

This function will add a link to your markup that will, when clicked, dynamically remove the surrounding partial form.
This should be placed inside the partial `_<association-object-singular>_fields`.

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

## Copyright

Copyright (c) 2010 nathanvda. See LICENSE for details.
