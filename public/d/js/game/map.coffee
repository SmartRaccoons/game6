class Moving extends window.o.ObjectBox
  position_new: ->
    @mesh.position.clone().add(@options.direction)
  position_update: -> @mesh.position = @position_new()


class Empty extends Moving
  # _imposter: BABYLON.PhysicsImpostor.BoxImpostor
  _default: {
    dimension: [1, 1, 1]
  }
  constructor: ->
    super
    c = _.random(-50, 50) + 180
    @color([c, c, c])



class Bullet extends Empty
  move: ->


class Object extends Moving
  # _imposter: BABYLON.PhysicsImpostor.BoxImpostor
  _default: {
    dimension: [1, 1, 1]
    color: [255, 0, 0]
  }

  bullet: ->
    if not @_bullet
      @_bullet = new Bullet({position: @mesh.position.asArray(), direction: @options.direction.clone()})
    @_bullet


V = BABYLON.Vector3

_vectors = {
  'up': new V(0, 1, 0)
  'down': new V(0, -1, 0)
  'left': new V(-1, 0, 0)
  'right': new V(1, 0, 0)
}

window.o.GameMap = class Map extends MicroEvent
  elements: {
    'wall': Empty
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

    @object = new Object({position: [0, 0, -1], direction: _vectors['up']})

  _add: (c, element)->
    if !@_map[c[2]]
      @_map[c[2]] = {}
    if !@_map[c[2]][c[1]]
      @_map[c[2]][c[1]] = {}
    @_map[c[2]][c[1]][c[0]] = element
    new @elements[element]({position: c})

  _get: (c)->
    if @_map[c.z] and @_map[c.z][c.y]
      return @_map[c.z][c.y][c.x]
    return false

  _key: (code)->
    p = [@object.mesh.position.x, @object.mesh.position.y, @object.mesh.position.z]
    if _vectors[code]
      @object.options.direction = _vectors[code]
      if !@_get(@object.position_new())
        @object.position_update()
    if code is 'action'
      bullet = @object.bullet()

  _render_before: ->

  _render_after: ->
