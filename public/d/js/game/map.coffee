class Empty extends window.o.ObjectBox
  # _imposter: BABYLON.PhysicsImpostor.BoxImpostor
  _default: {
    dimension: [1, 1, 1]
  }
  constructor: ->
    super
    c = _.random(-50, 50) + 180
    @color([c, c, c])


class Object extends window.o.ObjectBox
  # _imposter: BABYLON.PhysicsImpostor.BoxImpostor
  _default: {
    dimension: [1, 1, 1]
    color: [255, 0, 0]
  }


class V
  array: (p)-> [p.x, p.y, p.z]

  xyz: (p, v)->
    p.x = v[0]
    p.y = v[1]
    p.z = v[2]

  add: (v1, v2)->
    [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]]


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

    @object = new Object({position: [0, 0, -1]})
    @object._direction = [0, 1, 0]

  _add: (c, element)->
    if !@_map[c[2]]
      @_map[c[2]] = {}
    if !@_map[c[2]][c[1]]
      @_map[c[2]][c[1]] = {}
    @_map[c[2]][c[1]][c[0]] = element
    new @elements[element]({position: c})

  _get: (c)->
    if @_map[c[2]] and @_map[c[2]][c[1]] and @_map[c[2]][c[1]][c[0]]
      return @_map[c[2]][c[1]][c[0]]
    return false

  _key: (code)->
    p = [@object.mesh.position.x, @object.mesh.position.y, @object.mesh.position.z]
    v = {
      'up': [0, 1, 0]
      'down': [0, -1, 0]
      'left': [-1, 0, 0]
      'right': [1, 0, 0]
    }
    if v[code]
      @object._direction = v[code]
      p = V::add(V::array(@object.mesh.position), v[code])
      ob = @_get(p)
      if !ob
        V::xyz(@object.mesh.position, p)
    if code is 'action'
      console.info @object._direction


  _render_before: ->

  _render_after: ->
