# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $("li.li-node").each ->
    self = $(this)
    $.get("/nodes/#{self.attr('data-id')}/categories.json")
    .success (data) ->
      html = "<ul>"
      for category, probe_list of data
        html += "<li><ul>#{category}"
        for probe in probe_list
          html += "<li><a href='/nodes/#{self.attr('data-id')}/probe/#{probe.id}'>#{probe.name}</a></li>"
        html += "</ul></li>"
      self.append $(html)
    .error ->
      self.append( $ """
        <ul><li class="probes-error">Unable to get probes informations</li></ul>
      """)
