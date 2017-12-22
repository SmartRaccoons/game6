V = BABYLON.Vector3
_vectors = {
  'up': new V(0, 1, 0)
  'down': new V(0, -1, 0)
  'left': new V(-1, 0, 0)
  'right': new V(1, 0, 0)
}

class Moving extends window.o.ObjectBox
  position_new: ->
    @position_get().add(_vectors[@options.direction])

  position_update: -> @mesh.position = @position_new()

  position_get: ->
    @mesh.position.clone()


class Empty extends Moving
  _default: {
    dimension: [1, 1, 1]
  }
  constructor: ->
    super
    c = _.random(-50, 50) + 180
    @color([c, c, c])


class Bullet extends window.o.ObjectCylinder
  _default: {
    top: 0.2
    bottom: 1
    height: 1
  }
  constructor: ->
    super
    c = _.random(-50, 50) + 180
    @color([c, c, _.random(-50, 50) + 180])
    if @options.direction is 'down'
      @mesh.rotation.z = Math.PI
    if @options.direction is 'left'
      @mesh.rotation.z = Math.PI/2
    if @options.direction is 'right'
      @mesh.rotation.z = -Math.PI/2


class Player extends Moving
  _default: {
    dimension: [1, 1, 1]
    direction: Object.keys(_vectors)[0]
    color: [255, 0, 0]
  }


window.o.GameMap = class Map extends MicroEvent
  elements: {
    'wall': Empty
    'player': Player
    'bullet': Bullet
  }
  constructor: ->
    @_map = {}

    for i in [-5..5]
      for j in [-5..5]
        @_add([i, j, 0], 'wall')
    for i in [-5..5]
      @_add([i, -5, -1], 'wall')
      @_add([i, 5, -1], 'wall')
    for i in [-4..4]
      @_add([-5, i, -1], 'wall')
      @_add([5, i, -1], 'wall')

    @player = @_add([0, 0, -1], 'player')

  _add: (c, element, params={})->
    if !@_map[c[2]]
      @_map[c[2]] = {}
    if !@_map[c[2]][c[1]]
      @_map[c[2]][c[1]] = {}
    @_map[c[2]][c[1]][c[0]] = element
    new @elements[element](_.extend({position: c}, params))

  _get: (c)->
    if @_map[c.z] and @_map[c.z][c.y]
      return @_map[c.z][c.y][c.x]
    return false

  _switch: (p1, p2)->
    [@_map[p1.z][p1.y][p1.x], @_map[p2.z][p2.y][p2.x]] = [@_map[p2.z][p2.y][p2.x], @_map[p1.z][p1.y][p1.x]]

  _key: (code)->
    if _vectors[code]
      @player.options.direction = code
      if !@_get(@player.position_new())
        @_switch(@player.position_get(), @player.position_new())
        @player.position_update()
    if code is 'action'
      if !@_get(@player.position_new())
        @_add(@player.position_new().asArray(), 'bullet', {direction: @player.options.direction})

  _render_before: ->

  _render_after: ->
