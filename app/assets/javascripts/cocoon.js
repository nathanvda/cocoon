$.widget('ui.cocoon', {
  _init: function () {
    var cocoon = this;
    this.cocoonElementCounter = 0;
    this.element.find('.add_fields').click(function (e) {
      e.preventDefault();
      cocoon.addNew();
    });

    this._setupRemovableFields();
  },
  createNewId: function() {
    return (new Date().getTime() + this.cocoonElementCounter++);
  },
  options: {},
  _newContentBraced: function(id) {
    return '[' + id + ']$1';
  },
  _newContentUnderscored: function(id) {
    return '_' + id + '_$1';
  },
  _setupRemovableFields: function () {
    var cocoon = this;
    this.element.find('.remove_fields.dynamic, .remove_fields.existing').click(function (e) {
      e.preventDefault();
      cocoon.removeNode($(this));
    });
  },
  addNew: function() {
    var
      addElement = this.element.find('.add_fields'),
      assoc = addElement.data('association'),
      assocs = addElement.data('associations'),
      content = addElement.data('association-insertion-template'),
      insertionMethod = addElement.data('association-insertion-method') || addElement.data('association-insertion-position') || 'before',
      insertionNode = addElement.data('association-insertion-node'),
      insertionTraversal = addElement.data('association-insertion-traversal'),
      count = parseInt(addElement.data('count'), 10),
      regexpBraced = new RegExp('\\[new_' + assoc + '\\](.*?\\s)', 'g'),
      regexpUnderscored = new RegExp('_new_' + assoc + '_(\\w*)', 'g'),
      newId = this.createNewId(),
      newContent = content.replace(regexpBraced, this.createNewId(newId)),
      newContents = [];


    if (newContent == content) {
      regexpBraced     = new RegExp('\\[new_' + assocs + '\\](.*?\\s)', 'g');
      regexpUnderscored = new RegExp('_new_' + assocs + '_(\\w*)', 'g');
      newContent       = content.replace(regexpBraced, this._newContentBraced(newId));
    }

    newContent = newContent.replace(regexpUnderscored, this._newContentUnderscored(newId));
    newContents.push(newContent);

    count = (isNaN(count) ? 1 : Math.max(count, 1));
    count -= 1;

    while (count) {
      newId      = this.createNewId();
      newContent = content.replace(regexpBraced, this._newContentUnderscored(newId));
      newContent = newContent.replace(regexpUnderscored, this._newContentUnderscored(newId));
      newContents.push(newContent);

      count -= 1;
    }

    if (insertionNode){
      if (insertionTraversal){
        insertionNode = addElement[insertionTraversal](insertionNode);
      } else {
        insertionNode = insertionNode == "this" ? addElement : $(insertionNode);
      }
    } else {
      insertionNode = addElement.parent();
    }

    $.each(newContents, function(i, node) {
      var contentNode = $(node);

      insertionNode.trigger('cocoon:before-insert', [contentNode]);

      // allow any of the jquery dom manipulation methods (after, before, append, prepend, etc)
      // to be called on the node.  allows the insertion node to be the parent of the inserted
      // code and doesn't force it to be a sibling like after/before does. default: 'before'
      var addedContent = insertionNode[insertionMethod](contentNode);

      insertionNode.trigger('cocoon:after-insert', [contentNode]);
    });

    this._setupRemovableFields();

    return newContents;
  },
  removeNode: function(node) {
    var wrapperClass = node.data('wrapper-class') || 'nested-fields',
      nodeToDelete = node.closest('.' + wrapperClass),
      triggerNode = nodeToDelete.parent();

    triggerNode.trigger('cocoon:before-remove', [nodeToDelete]);

    var timeout = triggerNode.data('remove-timeout') || 0;

    setTimeout(function() {
      if (node.hasClass('dynamic')) {
        nodeToDelete.remove();
      } else {
        node.prev("input[type=hidden]").val("1");
        nodeToDelete.hide();
      }
      triggerNode.trigger('cocoon:after-remove', [nodeToDelete]);
    }, timeout);

    this.element.find('.remove_fields.existing.destroyed').each(function () {
      var $this = $(this),
        wrapperClass = $this.data('wrapper-class') || 'nested-fields';

      $this.closest('.' + wrapperClass).hide();
    });
  }
});
