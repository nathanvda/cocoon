(function($) {

  var cocoon_element_counter = 0;

  // unique id that will not conflict with rails
  var create_new_id = function() {
    return (new Date().getTime() + cocoon_element_counter++);
  }

  var newcontent_braced = function(id) {
    return '[' + id + ']$1';
  }

  var newcontent_underscored = function(id) {
    return '_' + id + '_$1';
  }
  
  // Format association to add text
  var regexp_bracer = function(target_association) {
    return new RegExp('\\[new_' + target_association + '\\](.*?\\s)', 'g')
  }
  
  // Format association to add text
  var regexp_underscorer = function(target_association) {
    return new RegExp('_new_' + target_association + '_(\\w*)', 'g')
  }

  // Return array of regex wrappers assocation ids & loop through all the id(s) 
  var associationIdBuilder = function(count, assoc, assocs, content) {
    
    var regexp_braced       = regexp_bracer(assoc),
        regexp_underscored  = regexp_underscorer(assoc)
        new_id              = create_new_id(),
        new_contents        = [];
    
    var new_content = content.replace(regexp_braced, newcontent_braced(new_id));
    
    // Toggle over to multiple associations if found
    if (new_content == content) {
      regexp_braced       = regexp_bracer(assocs);
      regexp_underscored  = regexp_underscorer(assocs);
      new_content   = content.replace(regexp_braced, newcontent_braced(new_id));
    }
    
    new_content = new_content.replace(regexp_underscored, newcontent_underscored(new_id));
    new_contents = [new_content]
    
    count = (isNaN(count) ? 1 : Math.max(count, 1));
    count -= 1;

    // If count over 0, we know to keep adding on rest of names with new ids
    while (count) {
      new_id      = create_new_id();
      new_content = content.replace(regexp_braced, newcontent_braced(new_id));
      new_content = new_content.replace(regexp_underscored, newcontent_underscored(new_id));
      new_contents.push(new_content);

      count -= 1;
    }
    return new_contents
  }

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();

    // Needed for both responsibilities
    var $this                 = $(this),
        new_contents          = [];
        
    // Association name builder vars
    var assoc                 = $this.data('association'),
        assocs                = $this.data('associations'),
        content               = $this.data('association-insertion-template'),
        count                 = parseInt($this.data('count'), 10);
        
    // association data insertion vars
    var insert_method   = $this.data('association-insertion-method'),
        insert_position = $this.data('association-insertion-position'), 
        insertionMethod       = insert_method || insert_position || 'before',
        // insertionNode         = $this.data('association-insertion-node'),
        // insertionTraversal    = $this.data('association-insertion-traversal');

    // Single or multiple assocations in proper format with non-rails unique id 
    new_contents = associationIdBuilder(count, assoc, assocs, content)

    var insertionNodeElem = getInsertionNodeElem($this)

    if( !insertionNodeElem || (insertionNodeElem.length == 0) ){
      console.warn("Couldn't find the element to insert the template. Make sure\
        your `data-association-insertion-*` on `link_to_add_association` is\
        correct.")
    }

    $.each(new_contents, function(i, node) {
      var contentNode = $(node);

      var before_insert = jQuery.Event('cocoon:before-insert');
      insertionNodeElem.trigger(before_insert, [contentNode]);

      if (!before_insert.isDefaultPrevented()) {
        // Allow any of the jquery dom manipulation methods 
        // ... (after, before, append, prepend, etc) to be called on the node.  
        // Allows the insertion node to be the parent of the inserted code and 
        // ... doesn't force it to be a sibling like after/before does. 
        // Default: 'before'
        var addedContent = insertionNodeElem[insertionMethod](contentNode);

        insertionNodeElem.trigger('cocoon:after-insert', [contentNode]);
      }
    });
  });

  // Jquery parent & positioning information
  var getInsertionNodeElem = function($this){
    var insertionNode         = $this.data('association-insertion-node'),
        insertionTraversal    = $this.data('association-insertion-traversal');
        
    if (!insertionNode){
      return $this.parent();
    }

    if (typeof insertionNode == 'function'){
      if(insertionTraversal){
        console.warn('association-insertion-traversal is ignored, because\
          association-insertion-node is given as a function.')
      }
      return insertionNode($this);
    }

    if(typeof insertionNode == 'string'){
      if (insertionTraversal){
        return $this[insertionTraversal](insertionNode);
      }else{
        return insertionNode == "this" ? $this : $(insertionNode);
      }
    }
  }

  $(document).on('click', '.remove_fields.dynamic, .remove_fields.existing', function(e) {
    var $this = $(this),
        wrapper_class = $this.data('wrapper-class') || 'nested-fields',
        node_to_delete = $this.closest('.' + wrapper_class),
        trigger_node = node_to_delete.parent();

    e.preventDefault();

    var before_remove = jQuery.Event('cocoon:before-remove');
    trigger_node.trigger(before_remove, [node_to_delete]);

    if (!before_remove.isDefaultPrevented()) {
      var timeout = trigger_node.data('remove-timeout') || 0;

      setTimeout(function() {
        if ($this.hasClass('dynamic')) {
            node_to_delete.detach();
        } else {
            $this.prev("input[type=hidden]").val("1");
            node_to_delete.hide();
        }
        trigger_node.trigger('cocoon:after-remove', [node_to_delete]);
      }, timeout);
    }
  });

  $(document).on("ready page:load turbolinks:load", function() {
    $('.remove_fields.existing.destroyed').each(function(i, obj) {
      var $this = $(this),
          wrapper_class = $this.data('wrapper-class') || 'nested-fields';

      $this.closest('.' + wrapper_class).hide();
    });
  });

})(jQuery);


