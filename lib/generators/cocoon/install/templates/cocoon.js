$(document).ready(function() {

  $('.add_fields').live('click', function() {
    var assoc   = $(this).attr('data-association');
    var content = $(this).siblings('#' + assoc + '_fields_template').html();
    var regexp_braced = new RegExp('\\[new_' + assoc + '\\]', 'g');
    var new_id  = new Date().getTime();
    var new_content = content.replace(regexp_braced, '[' + new_id + ']');
    if (new_content == content) {
        regexp_braced = new RegExp('\\[new_' + assoc + 's\\]', 'g');
        new_content = content.replace(regexp_braced, '[' + new_id + ']');
    }
    $(this).parent().before(new_content);
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