window.o.GameMap = class Map extends MicroEvent
  constructor: ->
    for i in [-4..4]
      for j in [-4..4]
        new window.o.ObjectBox({dimension: [0.9, 0.1, 0.9], position: [i, 0, j]})

  _render_before: ->

  _render_after: ->
