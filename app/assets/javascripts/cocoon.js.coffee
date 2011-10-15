(($) ->

  replace_in_content = (content, regexp_str, with_str) ->
    reg_exp = new RegExp regexp_str
    content.replace reg_exp, with_str
    return

  trigger_removal_callback = (node) ->
    node.parent().parent().trigger 'removal-callback'
    return

  $('.add_fields').live 'click', (e) ->
    e.preventDefault()

    assoc   = $(@).data 'association'
    assocs  = $(@).data 'associations'
    content = $(@).data 'template'
    insertionPosition = $(@).data 'association-insertion-position'
    insertionNode = $(@).data 'association-insertion-node'
    insertionCallback = $(@).data 'insertion-callback'
    removalCallback = $(@).data 'removal-callback'
    regexp_braced = new RegExp "\\[new_#{assoc}\\]", 'g'
    regexp_underscord = new RegExp "_new_#{assoc}_", 'g'
    new_id = new Date().getTime()
    newcontent_braced = "[#{new_id}]"
    newcontent_underscord = "_#{new_id}_"
    new_content = content.replace regexp_braced, "[#{new_id}]"

    if new_content == content
      regexp_braced = new RegExp "\\[new_#{assocs}\\]", 'g'
      regexp_underscord = new RegExp "_new_#{assocs}_", 'g'
      new_content = content.replace regexp_braced, "[#{new_id}]"

    new_content = new_content.replace regexp_underscord, newcontent_underscord

    if insertionNode
      insertionNode = if insertionNode == "this" then $ @ else $ insertionNode
    else
      insertionNode = $(@).parent()

    contentNode = $ new_content

    if insertionPosition == 'after'
      insertionNode.after contentNode
    else
      insertionNode.before contentNode

    if insertionCallback
      insertionCallback.call contentNode

    $(this).parent().trigger 'insertion-callback'

    return

  $('.remove_fields.dynamic').live 'click', (e) ->
    trigger_removal_callback $(@)
    e.preventDefault()
    $(@).closest(".nested-fields").remove()

  $('.remove_fields.existing').live 'click', (e) ->
    trigger_removal_callback $(@)
    e.preventDefault()
    $(@).prev("input[type=hidden]").val "1"
    $(@).closest(".nested-fields").hide()

  return
)(jQuery)