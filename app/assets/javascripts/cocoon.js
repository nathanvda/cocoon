(function($) {

  function replace_in_content(content, regexp_str, with_str) {
    reg_exp = new RegExp(regexp_str);
    content.replace(reg_exp, with_str);
  }

  function trigger_before_removal_callback(node) {
    node.trigger('cocoon:before-remove');
  }

  function trigger_after_removal_callback(node) {
    node.trigger('cocoon:after-remove');
  }

  $('.add_fields').live('click', function(e) {
    e.preventDefault();
    var $this                 = $(this),
        assoc                 = $this.data('association'),
        assocs                = $this.data('associations'),
        content               = $this.data('association-insertion-template'),
        insertionMethod       = $this.data('association-insertion-method') || $this.data('association-insertion-position') || 'before';
        insertionNode         = $this.data('association-insertion-node'),
        insertionTraversal    = $this.data('association-insertion-traversal');

    for(var i=0; i<2; i++) {
      a = [assoc, assocs][i]
      regexp_braced = new RegExp('\\[new_' + a + '\\]' + '(.*?(&gt;|>))', 'g')
      regexp_underscord     = new RegExp('_new_' + a + '_' + '(.*?(&gt;|>))', 'g');

      new_id                = new Date().getTime();
      new_braced     = '[' + new_id + ']';
      new_underscord = '_' + new_id + '_';

      content = content.replace(regexp_braced, new_braced + "$1") 
      content = content.replace(regexp_underscord, new_underscord + "$1");
    }

    if (insertionNode){
      if (insertionTraversal){
        insertionNode = $this[insertionTraversal](insertionNode)
      } else {
        insertionNode = insertionNode == "this" ? $this : $(insertionNode);
      }
    } else {
      insertionNode = $this.parent();
    }

    var contentNode = $(content);

    insertionNode.trigger('cocoon:before-insert');

    // allow any of the jquery dom manipulation methods (after, before, append, prepend, etc)
    // to be called on the node.  allows the insertion node to be the parent of the inserted
    // code and doesn't force it to be a sibling like after/before does. default: 'before'
    insertionNode[insertionMethod](contentNode);

    insertionNode.trigger('cocoon:after-insert');
  });

  $('.remove_fields.dynamic').live('click', function(e) {
    var $this = $(this);
    var trigger_node = $this.closest(".nested-fields").parent();
    trigger_before_removal_callback(trigger_node);
    e.preventDefault();
    $this.closest(".nested-fields").remove();
    trigger_after_removal_callback(trigger_node);
  });

  $('.remove_fields.existing').live('click', function(e) {
    var $this = $(this);
    var trigger_node = $this.closest(".nested-fields").parent();
    trigger_before_removal_callback(trigger_node);
    e.preventDefault();
    $this.prev("input[type=hidden]").val("1");
    $this.closest(".nested-fields").hide();
    trigger_after_removal_callback(trigger_node);
  });

})(jQuery);
