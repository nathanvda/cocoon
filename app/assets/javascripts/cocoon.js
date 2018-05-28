(function($) {

  var cocoon_element_counter = 0;

  var create_new_id = function() {
    return (new Date().getTime() + cocoon_element_counter++);
  }

  var newcontent_braced = function(id) {
    return '[' + id + ']$1';
  }

  var newcontent_underscord = function(id) {
    return '_' + id + '_$1';
  }

  var getInsertionNodeElem = function(insertionNode, insertionTraversal, $this){

    if (!insertionNode){
      return $this.parent();
    }

    if (typeof insertionNode == 'function'){
      if(insertionTraversal){
        console.warn('association-insertion-traversal is ignored, because association-insertion-node is given as a function.')
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

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();
    var $this                 = $(this),
        assoc                 = $this.data('association'),
	assocs                = $this.data('associations'),
        content               = $this.data('association-insertion-template'),
        count                 = parseInt($this.data('count'), 10),
        regexp_braced         = new RegExp('\\[new_' + assoc + '\\](.*?\\s)', 'g'),
        regexp_underscord     = new RegExp('_new_' + assoc + '_(\\w*)', 'g'),
        new_id                = null,
        new_content           = null;

    count = (isNaN(count) ? 1 : Math.max(count, 1));

    if (count == 1 && $this.data('ajax') && $this.data('ajaxdata')) {
      var cid                 = $this.data("ajaxdata"),
          mdata               = {},
          regexp_inputid      = new RegExp('<input .*id="[^"]*_' + assoc + 
			  '_id"', 'g'),
          regexp_inputid2     = new RegExp('<input .*id="[^"]*_' + assocs + 
			  '_id"', 'g');
      mdata[cid] = $('#' + cid).val();

      $.ajax($this.data("ajax"), {
        type: 'GET',
        dataType: 'json', 
        data: mdata
      }).done(function(pnew_id) { 
        if (typeof pnew_id == "string" || typeof pnew_id == "number") {
          new_content = content.replace(regexp_inputid, 
            '$& value="' + pnew_id + '" ');
          new_content = new_content.replace(regexp_inputid2, 
            '$& value="' + pnew_id + '" ');
	  new_id = pnew_id;
        } else {
          if (!(assoc in pnew_id)) {
            alert( "Cocoon request failed, json returned should include key " 
		    + assoc + " with identification of new association");
          }
          new_id = pnew_id[assoc]
          new_content = content.replace(regexp_inputid, 
            '$& value="' + new_id + '" ');
          new_content = new_content.replace(regexp_inputid2, 
            '$& value="' + new_id + '" ');
          for (var i in pnew_id) {
            if (i != assoc) {
              // We tried by converting to jquery and using val and html but
              // didn't change the generated html
              var regexp_secinputid = new RegExp(
                  '<input .*id="[^"]*_' + i + '_attributes_id"', 'g');
              new_content = new_content.replace(regexp_secinputid, 
                  '$& value="' + pnew_id[i] + '" ');
              var regexp_input = new RegExp(
	          '<input .*id="[^"]*_new_' + assoc + '_' + i + '"', 'g');
              new_content = new_content.replace(regexp_input, 
                  '$& value="' + pnew_id[i] + '" ');
              var regexp_input2 = new RegExp(
	          '<input .*id="[^"]*_new_' + assocs + '_' + i + '"', 'g');
              new_content = new_content.replace(regexp_input2, 
                  '$& value="' + pnew_id[i] + '" ');
              var regexp_select = new RegExp(
	          '<select .*id="[^"]*_new_' + assoc + '_' + i + 
                  '".* <option value="' + pnew_id[i] + '"', 'g');
              new_content = new_content.replace(regexp_input, 
                  '$& selected');
            } 
          }
        }
        new_content2 = new_content.replace(regexp_braced, newcontent_braced(new_id));
        if (new_content2 != new_content) {
          new_content2 = new_content2.replace(regexp_underscord,
              newcontent_underscord(new_id));
        }
	add_fields($this, assoc, assocs, new_content2, count, regexp_braced,
			new_id, new_content2);
      }).fail(function(jqXHR, textStatus) {
        alert( "Cocoon request failed: " + textStatus );
      });
    } else {
      new_id = create_new_id();
      new_content = content.replace(regexp_braced, newcontent_braced(new_id));
      add_fields($this, assoc, assocs, content, count, regexp_braced, 
		      new_id, new_content);
    }
  });


  /* Complete event click on .add_fields once we know new_id */
  function add_fields($this, assoc, assocs, content, count, regexp_braced, 
		  new_id, new_content)  {
    var insertionMethod       = $this.data('association-insertion-method') || $this.data('association-insertion-position') || 'before',
        insertionNode         = $this.data('association-insertion-node'),
        insertionTraversal    = $this.data('association-insertion-traversal'),
        regexp_underscord     = new RegExp('_new_' + assoc + '_(\\w*)', 'g'),
        new_contents          = [];

    if (new_content == content) {
      regexp_braced     = new RegExp('\\[new_' + assocs + '\\](.*?\\s)', 'g');
      regexp_underscord = new RegExp('_new_' + assocs + '_(\\w*)', 'g');
      new_content       = content.replace(regexp_braced, newcontent_braced(new_id));
    }

    new_content = new_content.replace(regexp_underscord, newcontent_underscord(new_id));
    new_contents = [new_content];

    count -= 1;

    while (count) {
      new_id      = create_new_id();
      new_content = content.replace(regexp_braced, newcontent_braced(new_id));
      new_content = new_content.replace(regexp_underscord, newcontent_underscord(new_id));
      new_contents.push(new_content);

      count -= 1;
    }

    var insertionNodeElem = getInsertionNodeElem(insertionNode, insertionTraversal, $this)

    if( !insertionNodeElem || (insertionNodeElem.length == 0) ){
      console.warn("Couldn't find the element to insert the template. Make sure your `data-association-insertion-*` on `link_to_add_association` is correct.")
    }

    $.each(new_contents, function(i, node) {
      var contentNode = $(node);

      var before_insert = jQuery.Event('cocoon:before-insert');
      insertionNodeElem.trigger(before_insert, [contentNode]);

      if (!before_insert.isDefaultPrevented()) {
        // allow any of the jquery dom manipulation methods (after, before, append, prepend, etc)
        // to be called on the node.  allows the insertion node to be the parent of the inserted
        // code and doesn't force it to be a sibling like after/before does. default: 'before'
        var addedContent = insertionNodeElem[insertionMethod](contentNode);

        insertionNodeElem.trigger('cocoon:after-insert', [contentNode]);
      }
    });
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


