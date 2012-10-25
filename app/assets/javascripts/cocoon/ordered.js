//= require jquery-ui
//
(function($) {
  $(function() {
    $('li[data-ordered_by]').each(function(index, element) {
      var field = $(element).data('ordered_by');
      var fieldSearch = "[name*='[" + field + "]']"

      $(element).sortable({
        items: '.nested-fields',
        stop: function(e, ui) {
          $(element).find(fieldSearch).each(function(index, element) {
            $(element).val(index);
          });
        }
      });

      $(element).bind('cocoon:after-insert', function(e, node) {
        var nextOrder = 0;

        $(element).find(fieldSearch).each(function() {
          nextOrder = Math.max(nextOrder, Number($(this).val()) + 1);
        });

        $(node).find(fieldSearch).val(nextOrder)
      });
    });
  });
})(jQuery);
