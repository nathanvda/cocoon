(function($) {

  var cocoon_element_counter = 0;

  function replace_in_content(content, regexp_str, with_str) {
    reg_exp = new RegExp(regexp_str);
    content.replace(reg_exp, with_str);
  }


  $('.add_fields').live('click', function(e) {
    e.preventDefault();
    var $this                 = $(this),
        assoc                 = $this.data('association'),
        assocs                = $this.data('associations'),
        content               = $this.data('association-insertion-template'),
        insertionMethod       = $this.data('association-insertion-method') || $this.data('association-insertion-position') || 'before';
        insertionNode         = $this.data('association-insertion-node'),
        insertionTraversal    = $this.data('association-insertion-traversal'),
        regexp_braced         = new RegExp('\\[new_' + assoc + '\\](.*?\\s)', ''),
        regexp_underscord     = new RegExp('_new_' + assoc + '_(\\w*)', ''),
        new_id                = new Date().getTime() + cocoon_element_counter++,
        newcontent_braced     = '[' + new_id + ']',
        newcontent_underscord = '_' + new_id + '_';

    var content_lines = content.split(/\r\n|\r|\n/);
    for (var i = 0; i < content_lines.length; i++) {
      content_lines[i] = content_lines[i].replace(regexp_braced, '[' + new_id + ']');
    }
    var new_content = content_lines.join("\n");


    if (new_content == content.split(/\r\n|\r|\n/).join("\n")) {
      //regexp_braced and regexp_underscord were aimed at a single assocation (using variable assoc for replace()),
      //but it had no effect in the above lines so now try to use variable assocs instead of assoc for replace
        regexp_braced     = new RegExp('\\[new_' + assocs + '\\]', '');
        regexp_underscord = new RegExp('_new_' + assocs + '_', '');
        var new_content_lines = new_content.split(/\r\n|\r|\n/);
        for (var i = 0; i < new_content_lines.length; i++) {
          new_content_lines[i] = new_content_lines[i].replace(regexp_braced, '[' + new_id + ']');
        }
        new_content = new_content_lines.join("\n");
    }

    var new_content_lines = new_content.split(/\r\n|\r|\n/);
    for (var i = 0; i < new_content_lines.length; i++) {
      new_content_lines[i] = new_content_lines[i].replace(regexp_underscord, newcontent_underscord);
    }
    new_content = new_content_lines.join("\n");

    if (insertionNode){
      if (insertionTraversal){
        insertionNode = $this[insertionTraversal](insertionNode)
      } else {
        insertionNode = insertionNode == "this" ? $this : $(insertionNode);
      }
    } else {
      insertionNode = $this.parent();
    }

    var contentNode = $(new_content);

    insertionNode.trigger('cocoon:before-insert', [contentNode]);

    // allow any of the jquery dom manipulation methods (after, before, append, prepend, etc)
    // to be called on the node.  allows the insertion node to be the parent of the inserted
    // code and doesn't force it to be a sibling like after/before does. default: 'before'
    var addedContent = insertionNode[insertionMethod](contentNode);

    insertionNode.trigger('cocoon:after-insert', [contentNode]);
  });


  $('.remove_fields.dynamic, .remove_fields.existing').live('click', function(e) {
    var $this = $(this);
    var node_to_delete = $this.closest(".nested-fields");
    var trigger_node = node_to_delete.parent();

    e.preventDefault();

    trigger_node.trigger('cocoon:before-remove', [node_to_delete]);


    var timeout = trigger_node.data('remove-timeout') || 0;

    setTimeout(function() {
      if ($this.hasClass('dynamic')) {
          $this.closest(".nested-fields").remove();
      } else {
          $this.prev("input[type=hidden]").val("1");
          $this.closest(".nested-fields").hide();
      }
      trigger_node.trigger('cocoon:after-remove', [node_to_delete]);
    }, timeout);
  });

})(jQuery);
