$(document).ready(function() {

  function replace_in_content(content, regexp_str, with_str) {
      reg_exp = new RegExp(regexp_str);
      content.replace(reg_exp, with_str)
  }


  $('.add_fields').live('click', function() {
    var assoc   = $(this).attr('data-association');
    var assocs  = $(this).attr('data-associations');
    var content = $(this).attr('data-template');
    var insertionPosition = $(this).attr('data-association-insertion-position');
    var insertionNode = $(this).attr('data-association-insertion-node');
    var insertionCallback = $(this).data('insertion-callback');
    var regexp_braced = new RegExp('\\[new_' + assoc + '\\]', 'g');
    var regexp_underscord = new RegExp('_new_' + assoc + '_', 'g');
    var new_id  = new Date().getTime();
    var newcontent_braced = '[' + new_id + ']';
    var newcontent_underscord = '_' + new_id + '_';
    var new_content = content.replace(regexp_braced, '[' + new_id + ']');
    if (new_content == content) {
        regexp_braced = new RegExp('\\[new_' + assocs + '\\]', 'g');
        regexp_underscord = new RegExp('_new_' + assocs + '_', 'g');
        new_content = content.replace(regexp_braced, '[' + new_id + ']');
    }
    new_content = new_content.replace(regexp_underscord, newcontent_underscord);

    if (insertionNode) {
      insertionNode = $(insertionNode);
    }
    else {
      insertionNode = $(this).parent();
    }

    var contentNode = $(new_content);
    
    if (insertionPosition == 'after'){
      insertionNode.after(contentNode);
    } else {
      insertionNode.before(contentNode); 
    }

    if(insertionCallback){
      insertionCallback.call(contentNode);
    }
    
    return false;
  });

  $('.remove_fields.dynamic').live('click', function() {
    $(this).closest(".nested-fields").remove();
    return false;
  });

  $('.remove_fields.existing').live('click', function() {
    $(this).prev("input[type=hidden]").val("1");
    $(this).closest(".nested-fields").hide();
    return false;
  });

});

