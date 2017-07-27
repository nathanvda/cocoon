# cocoon

[![Build Status](https://travis-ci.org/nathanvda/cocoon.png?branch=master)](https://travis-ci.org/nathanvda/cocoon)

Cocoon makes it easier to handle nested forms.

Nested forms are forms that handle nested models and attributes in one form;
e.g. a project with its tasks or an invoice with its line items.

Cocoon is form builder-agnostic, so it works with standard Rails, [Formtastic](https://github.com/justinfrench/formtastic), or [SimpleForm](https://github.com/plataformatec/simple_form).
It is compatible with rails 3, 4 and 5.

This project is not related to [Apache Cocoon](http://cocoon.apache.org/).

## Prerequisites

This gem depends on jQuery, so it's most useful in a Rails project where you are already using jQuery.
Furthermore, I would advise you to use either [Formtastic](https://github.com/justinfrench/formtastic) or [SimpleForm](https://github.com/plataformatec/simple_form).

## Installation

Inside your `Gemfile` add the following:

```ruby
gem "cocoon"
```

> Please note that for rails 4 you will need at least v1.2.0 or later.

### Rails 3.1+/Rails 4/Rails 5

Add the following to `application.js` so it compiles to the asset pipeline:

```ruby
//= require cocoon
```

### Rails 3.0.x

If you are using Rails 3.0.x, you need to run the installation task (since rails 3.1 this is no longer needed):

```bash
rails g cocoon:install
```

This will install the Cocoon JavaScript file. In your application layout, add the following below the default javascripts:

```haml
= javascript_include_tag :cocoon
```

## Basic Usage

Suppose you have a `Project` model:

```bash
rails g scaffold Project name:string description:string
```

And a project has many `tasks`:

```bash
rails g model Task description:string done:boolean project:belongs_to
```

Your models are associated like this:

```ruby
class Project < ActiveRecord::Base
  has_many :tasks, inverse_of: :project
  accepts_nested_attributes_for :tasks, reject_if: :all_blank, allow_destroy: true
end

class Task < ActiveRecord::Base
  belongs_to :project
end
```

> *Rails 5 Note*: since rails 5 a `belongs_to` relation is by default required. While this absolutely makes sense, this also means
> associations have to be declared more explicitly. 
> When saving nested items, theoretically the parent is not yet saved on validation, so rails needs help to know
> the link between relations. There are two ways: either declare the `belongs_to` as `optional: false`, but the
> cleanest way is to specify the `inverse_of:` on the `has_many`. That is why we write : `has_many :tasks, inverse_of: :project` 
 
 

Now we want a project form where we can add and remove tasks dynamically.
To do this, we need the fields for a new or existing `task` to be defined in a partial
named `_task_fields.html`.

### Strong Parameters Gotcha

To destroy nested models, rails uses a virtual attribute called `_destroy`.
When `_destroy` is set, the nested model will be deleted. If the record is persisted, rails performs `id` field lookup to destroy the real record, so if `id` wasn't specified, it will treat current set of parameters like a parameters for a new record.

When using strong parameters (default in rails 4), you need to explicitly
add both `:id` and `:_destroy` to the list of permitted parameters.

E.g. in your `ProjectsController`:

```ruby
  def project_params
    params.require(:project).permit(:name, :description, tasks_attributes: [:id, :description, :done, :_destroy])
  end
```

## Examples

Cocoon's default configuration requires `link_to_add_association` and associated partials to
be properly wrapped with elements. The examples below illustrate simple layouts.

Please note these examples rely on the `haml` gem (instead of the default `erb` views).

### Formtastic

In our `projects/_form` partial we'd write:

```haml
= semantic_form_for @project do |f|
  = f.inputs do
    = f.input :name
    = f.input :description
    %h3 Tasks
    #tasks
      = f.semantic_fields_for :tasks do |task|
        = render 'task_fields', f: task
      .links
        = link_to_add_association 'add task', f, :tasks
    = f.actions do
      = f.action :submit
```

And in our `_task_fields` partial we'd write:

```haml
.nested-fields
  = f.inputs do
    = f.input :description
    = f.input :done, as: :boolean
    = link_to_remove_association "remove task", f
```

The example project [cocoon_formtastic_demo](https://github.com/nathanvda/cocoon_formtastic_demo) demonstrates this.

### SimpleForm

In our `projects/_form` partial we'd write:

```haml
= simple_form_for @project do |f|
  = f.input :name
  = f.input :description
  %h3 Tasks
  #tasks
    = f.simple_fields_for :tasks do |task|
      = render 'task_fields', f: task
    .links
      = link_to_add_association 'add task', f, :tasks
  = f.submit
```

In our `_task_fields` partial we write:

```haml
.nested-fields
  = f.input :description
  = f.input :done, as: :boolean
  = link_to_remove_association "remove task", f
```

The example project [cocoon_simple_form_demo](https://github.com/nathanvda/cocoon_simple_form_demo) demonstrates this.

### Standard Rails forms

In our `projects/_form` partial we'd write:

```haml
= form_for @project do |f|
  .field
    = f.label :name
    %br
    = f.text_field :name
  .field
    = f.label :description
    %br
    = f.text_field :description
  %h3 Tasks
  #tasks
    = f.fields_for :tasks do |task|
      = render 'task_fields', f: task
    .links
      = link_to_add_association 'add task', f, :tasks
  = f.submit
```

In our `_task_fields` partial we'd write:

```haml
.nested-fields
  .field
    = f.label :description
    %br
    = f.text_field :description
  .field
    = f.check_box :done
    = f.label :done
  = link_to_remove_association "remove task", f
```

## How it works

Cocoon defines two helper functions:

### link_to_add_association

This function adds a link to your markup that, when clicked, dynamically adds a new partial form for the given association.
This should be called within the form builder.

`link_to_add_association` takes four parameters:

- name: the text to show in the link
- f: the form builder
- association: the name of the association (plural) of which a new instance needs to be added (symbol or string).
- html_options: extra html-options (see [`link_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
  There are some special options, the first three allow to control the placement of the new link-data:
  - `data-association-insertion-traversal` : the jquery traversal method to allow node selection relative to the link. `closest`, `next`, `children`, etc. Default: absolute selection
  - `data-association-insertion-node` : the jquery selector of the node as string, or a function that takes the `link_to_add_association` node as the parameter and returns a node. Default: parent node
  - `data-association-insertion-method` : jquery method that inserts the new data. `before`, `after`, `append`, `prepend`, etc. Default: `before`
  - `data-association-insertion-position` : old method specifying where to insert new data.
      - this setting still works but `data-association-insertion-method` takes precedence. may be removed in a future version.
  - `partial`: explicitly declare the name of the partial that will be used
  - `render_options` : options passed through to the form-builder function (e.g. `simple_fields_for`, `semantic_fields_for` or `fields_for`).
                       If it contains a `:locals` option containing a hash, that is handed to the partial.
  - `wrap_object` : a proc that will allow to wrap your object, especially useful if you are using decorators (e.g. draper). See example lower.
  - `force_non_association_create`: if true, it will _not_ create the new object using the association (see lower)
  - `form_name` : the name of the form parameter in your nested partial. By default this is `f`.

Optionally, you can omit the name and supply a block that is captured to render the link body (if you want to do something more complicated).

#### :render_options
Inside the `html_options` you can add an option `:render_options`, and the containing hash will be handed down to the form builder for the inserted
form.

When using Twitter Bootstrap and SimpleForm together, `simple_fields_for` needs the option `wrapper: 'inline'` which can
be handed down as follows:

(Note: In certain newer versions of simple_form, the option to use is `wrapper: 'bootstrap'`.)

```haml
= link_to_add_association 'add something', f, :something,
    render_options: { wrapper: 'inline' }
```

To specify locals that needed to handed down to the partial:

```haml
= link_to_add_association 'add something', f, :something,
    render_options: {locals: { sherlock: 'Holmes' }}
```

#### :partial

To override the default partial name, e.g. because it shared between multiple views:

```haml
= link_to_add_association 'add something', f, :something,
    partial: 'shared/something_fields'
```

#### :wrap_object

If you are using decorators, the normal instantiation of the associated object will not be enough. You actually want to generate the decorated object.

A simple decorator would look like:

```ruby
class CommentDecorator
  def initialize(comment)
    @comment = comment
  end

  def formatted_created_at
    @comment.created_at.to_formatted_s(:short)
  end

  def method_missing(method_sym, *args)
    if @comment.respond_to?(method_sym)
      @comment.send(method_sym, *args)
    else
      super
    end
  end
end
```

To use this:

```haml
= link_to_add_association('add something', @form_obj, :comments,
    wrap_object: Proc.new {|comment| CommentDecorator.new(comment) })
```

Note that the `:wrap_object` expects an object that is _callable_, so any `Proc` will do. So you could as well use it to do some fancy extra initialisation (if needed).
But note you will have to return the (nested) object you want used.
E.g.


```haml
= link_to_add_association('add something', @form_obj, :comments,
    wrap_object: Proc.new { |comment| comment.name = current_user.name; comment })
```

#### :force_non_association_create

In normal cases we create a new nested object using the association relation itself. This is the cleanest way to create
a new nested object.

This used to have a side-effect: for each call of `link_to_add_association` a new element was added to the association.
This is no longer the case.

For backward compatibility we keep this option for now. Or if for some specific reason you would
really need an object to be _not_ created on the association.

Example use:

```haml
= link_to_add_association('add something', @form_obj, :comments,
    force_non_association_create: true)
```

By default `:force_non_association_create` is `false`.

### link_to_remove_association

This function will add a link to your markup that, when clicked, dynamically removes the surrounding partial form.
This should be placed inside the partial `_<association-object-singular>_fields`.

It takes three parameters:

- name: the text to show in the link
- f: referring to the containing form-object
- html_options: extra html-options (see `link_to`)

Optionally you could also leave out the name and supply a block that is captured to give the name (if you want to do something more complicated).

Optionally, you can add an html option called `wrapper_class` to use a different wrapper div instead of `.nested-fields`.
The class should be added without a preceding dot (`.`).

> Note: the javascript behind the generated link relies on the presence of a wrapper class (default `.nested-fields`) to function correctly.

Example:
```haml
= link_to_remove_association('remove this', @form_obj,
  { wrapper_class: 'my-wrapper-class' })
```

### Callbacks (upon insert and remove of items)

On insertion or removal the following events are triggered:

* `cocoon:before-insert`: called before inserting a new nested child
* `cocoon:after-insert`: called after inserting
* `cocoon:before-remove`: called before removing the nested child
* `cocoon:after-remove`: called after removal

To listen to the events in your JavaScript:

```javascript
  $('#container').on('cocoon:before-insert', function(e, insertedItem) {
    // ... do something
  });
```

...where `e` is the event and the second parameter is the inserted or removed item. This allows you to change markup, or
add effects/animations (see example below).


If in your view you have the following snippet to select an `owner`:

```haml
#owner
  #owner_from_list
    = f.association :owner, collection: Person.all(order: 'name'), prompt: 'Choose an existing owner'
  = link_to_add_association 'add a new person as owner', f, :owner
```

This will either let you select an owner from the list of persons, or show the fields to add a new person as owner.

The callbacks can be added as follows:

```javascript
$(document).ready(function() {
    $('#owner')
      .on('cocoon:before-insert', function() {
        $("#owner_from_list").hide();
        $("#owner a.add_fields").hide();
      })
      .on('cocoon:after-insert', function() {
        /* ... do something ... */
      })
      .on("cocoon:before-remove", function() {
        $("#owner_from_list").show();
        $("#owner a.add_fields").show();
      })
      .on("cocoon:after-remove", function() {
        /* e.g. recalculate order of child items */
      });

    // example showing manipulating the inserted/removed item

    $('#tasks')
      .on('cocoon:before-insert', function(e,task_to_be_added) {
        task_to_be_added.fadeIn('slow');
      })
      .on('cocoon:after-insert', function(e, added_task) {
        // e.g. set the background of inserted task
        added_task.css("background","red");
      })
      .on('cocoon:before-remove', function(e, task) {
        // allow some time for the animation to complete
        $(this).data('remove-timeout', 1000);
        task.fadeOut('slow');
      });
});
```

Note that for the callbacks to work there has to be a surrounding container to which you can bind the callbacks.

When adding animations and effects to make the removal of items more interesting, you will also have to provide a timeout.
This is accomplished by the following line:

```javascript
$(this).data('remove-timeout', 1000);
```

You could also immediately add this to your view, on the `.nested-fields` container (or the `wrapper_class` element you are using).

### Control the Insertion Behaviour

The default insertion location is at the back of the current container. But we have added two `data-` attributes that are read to determine the insertion-node and -method.

For example:

```javascript
$(document).ready(function() {
    $("#owner a.add_fields").
      data("association-insertion-method", 'before').
      data("association-insertion-node", 'this');
});
```

The `association-insertion-node` will determine where to add it. You can choose any selector here, or specify this. Also, you can pass a function that returns an arbitrary node. The default is the parent-container, if you don't specify anything.

The `association-insertion-method` will determine where to add it in relation with the node. Any jQuery DOM Manipulation method can be set but we recommend sticking to any of the following: `before`, `after`, `append`, `prepend`. It is unknown at this time what others would do.

The `association-insertion-traversal` will allow node selection to be relative to the link. 

For example:

```javascript
$(document).ready(function() {
    $("#owner a.add_fields").
      data("association-insertion-method", 'append').
      data("association-insertion-traversal", 'closest').
      data("association-insertion-node", '#parent_table');
});
```

(if you pass `association-insertion-node` as a function, this value will be ignored)


Note, if you want to add templates to the specific location which is:

- not a direct parent or sibling of the link
- the link appears multiple times - for instance, inside a deeply nested form

you need to specify `association-insertion-node` as a function.


For example, suppose Task has many SubTasks in the [Example](#examples), and have subtask forms like the following.

```haml
.row
  .col-lg-12
    .add_sub_task= link_to_add_association 'add a new sub task', f, :sub_tasks
.row
  .col-lg-12
    .sub_tasks_form
      fields_for :sub_tasks do |sub_task_form|
        = render 'sub_task_fields', f: sub_task_form
```

Then this will do the thing.

```javascript
$(document).ready(function() {
    $(".add_sub_task a").
      data("association-insertion-method", 'append').
      data("association-insertion-node", function(link){
        return link.closest('.row').next('.row').find('.sub_tasks_form')
      });
});
```


### Partial

If no explicit partial name is given, `cocoon` looks for a file named `_<association-object_singular>_fields`.
To override the default partial use the `:partial` option.

For the JavaScript to behave correctly, the partial should start with a container (e.g. `div`) of class `.nested-fields`, or a class of your choice which you can define in the `link_to_remove_association` method.

There is no limit to the amount of nesting, though.

## I18n

As you seen in previous sections, the helper method `link_to_add_association` treats the first parameter as a name. Additionally, if it's skipped and the `form` object is passed as the first one, then **Cocoon** names it using **I18n**.

It allows to invoke helper methods like this:

```haml
= link_to_add_association form_object, :tasks
= link_to_remove_association form_object
```

instead of:

```haml
= link_to_add_association "Add task", form_object, :tasks
= link_to_remove_association "remove task", form_object
```

**Cocoon** uses the name of `association` as a translations scope key. If custom translations for association is not present it fallbacks to default name. Example of translations tree:

```yaml
en:
  cocoon:
    defaults:
      add: "Add record"
      remove: "Remove record"
    tasks:
      add: "Add new task"
      remove: "Remove old task"
```

Note that `link_to_remove_association` does not require `association` name as an argument. In order to get correct translation key, **Cocoon** tableizes `class` name of the target object of form builder (`form_object.object` from previous example).

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


## Contributors

The list of contributors just keeps on growing. [Check it out!](https://github.com/nathanvda/cocoon/graphs/contributors)
I would really really like to thank all of them. They make cocoon more awesome every day. Thanks.

## Todo

* add more sample relations: `has_many :through`, `belongs_to`, ...
* improve the tests (test the javascript too)(if anybody wants to lend a hand ...?)

## Copyright

Copyright (c) 2010 Nathan Van der Auwera. See LICENSE for details.

## Not Related To Apache Cocoon

Please note that this project is not related to the Apache Cocoon web framework project.

[Apache Cocoon](http://cocoon.apache.org/), Cocoon, and Apache are either registered trademarks or trademarks of the [Apache Software Foundation](http://www.apache.org/) in the United States and/or other countries.
