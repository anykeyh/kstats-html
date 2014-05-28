$(document).on 'ready page:load', ->
  jQuery ->
    $("a[rel~=popover], .has-popover").popover()
    $("a[rel~=tooltip], .has-tooltip").tooltip()
