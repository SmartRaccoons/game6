V = BABYLON.Vector3
_vectors = {
  'up': new V(0, 1, 0)
  'down': new V(0, -1, 0)
  'left': new V(-1, 0, 0)
  'right': new V(1, 0, 0)
}

class Moving
  position_new: ->
    @position_get().add(_vectors[@options.direction])

  position_update: -> @mesh.position = @position_new()

  position_get: ->
    @mesh.position.clone()


class Empty extends window.o.ObjectBox
  _default: {
    dimension: [1, 1, 1]
  }
  constructor: ->
    super
    c = _.random(-50, 50) + 180
    @color([c, c, c])


class Bullet extends window.o.ObjectCylinder
  _.extend this::, Moving::
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


class Player extends window.o.ObjectBox
  _.extend this::, Moving::
  _default: {
    dimension: [1, 1, 1]
    direction: Object.keys(_vectors)[0]
    color: [255, 0, 0]
  }
  constructor: ->
    super
    @_bullets = []


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

  _switch: (o, check = false)->
    p2 = o.position_new()
    if check and @_get(p2)
      return
    p1 = o.position_get()
    [@_map[p1.z][p1.y][p1.x], @_map[p2.z][p2.y][p2.x]] = [@_map[p2.z][p2.y][p2.x], @_map[p1.z][p1.y][p1.x]]
    o.position_update()

  _remove: (o)->
    p1 = o.position_get()
    @_map[p1.z][p1.y][p1.x] = false
    o.remove()

  _key: (code)->
    if _vectors[code]
      @player.options.direction = code
      @_switch(@player, true)
      @player._bullets.forEach (b)=> @_move_bullet(b)
    if code is 'action'
      if !@_get(@player.position_new())
        bullet = @_add(@player.position_new().asArray(), 'bullet', {direction: @player.options.direction})
        @player._bullets.push bullet
        # bullet._action({
        #   click: => @_move_bullet(bullet)
        # })

  _move_bullet: (bullet)->
    ob = @_get(bullet.position_new())
    if !ob
      @_switch(bullet)
    if ob is 'wall'
      @_remove(bullet)
    if ob is 'player'
      @_remove(bullet)
      @_remove(@player)

  _render_before: ->

  _render_after: ->
