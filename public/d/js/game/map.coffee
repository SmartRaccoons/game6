V = BABYLON.Vector3
_vectors = {
  'up': new V(0, 1, 0)
  'down': new V(0, -1, 0)
  'left': new V(-1, 0, 0)
  'right': new V(1, 0, 0)
}

class Moving
  position_new: ->
    if @_port
      return @_port.mesh.position.clone()
    @position_get().add(_vectors[@options.direction].clone().scaleInPlace(@_scale or 1))

  position_update: ->
    @mesh.position = @position_new()
    if @_port
      @_port = false

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
  _.extend @::, Moving::
  _default: {
    top: 0.2
    bottom: 1
    height: 1
  }
  _scale: 2
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


class Port extends window.o.ObjectCylinder
  _default: {
    top: 0.5
    bottom: 0.5
    height: 0.5
  }

  constructor: ->
    super
    c = _.random(-50, 50) + 180
    @color([c, _.random(-50, 50) + 180, c])


class Player extends window.o.ObjectBox
  _.extend @::, Moving::
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
    'port': Port
  }
  constructor: ->
    @_map = {}
    @_ports = {}
    # for i in [-10..10]
    #   for j in [-10..10]
    #     @_add([i, j, 0], 'wall')
    size = 10
    for i in [-size..size]
      @_add([i, -size, -1], 'wall')
      @_add([i, size, -1], 'wall')
    for i in [-(size-1)..(size-1)]
      @_add([-size, i, -1], 'wall')
      @_add([size, i, -1], 'wall')
    @_add([2, 0, -1], 'port', {connector: 1})
    @_add([-2, 2, -1], 'port', {connector: 1})
    @player = @_add([0, 0, -1], 'player')

  _add_map: (c, ob)->
    if !@_map[c[2]]
      @_map[c[2]] = {}
    if !@_map[c[2]][c[1]]
      @_map[c[2]][c[1]] = {}
    if !@_map[c[2]][c[1]][c[0]]
      @_map[c[2]][c[1]][c[0]] = []
    @_map[c[2]][c[1]][c[0]].push ob

  _remove_map: (c, ob)-> @_map[c[2]][c[1]][c[0]].splice(@_map[c[2]][c[1]][c[0]].indexOf(ob), 1)

  _add: (c, element, params={})->
    ob = new @elements[element](_.extend({position: c}, params))
    ob._type = element
    ob.bind 'remove', => @_remove_map(ob.position_get().asArray(), ob)
    if ob._type is 'port'
      if !@_ports[params.connector]
        @_ports[params.connector] = []
      @_ports[params.connector].push ob
    @_add_map(c, ob)
    ob

  _add_bullet: (c, direction)->
    bullet = @_add(c, 'bullet', {direction: direction})
    bullet.bind 'collide:wall', (wall)=>
      bullet.remove()
    bullet.bind 'collide:player', =>
      bullet.remove()
      @player.remove()
    bullet.bind 'collide:port', (ob)=>
      connector = @_ports[ob.options.connector].filter( (port)-> port._id isnt ob._id )[0]
      bullet._port = connector
      @_move(bullet)
    @player._bullets.push bullet

  _get: (c)->
    if @_map[c.z] and @_map[c.z][c.y] and @_map[c.z][c.y][c.x] and @_map[c.z][c.y][c.x].length > 0
      return @_map[c.z][c.y][c.x]
    return false

  _move: (o, check = false)->
    p2 = o.position_new()
    if check and @_get(p2)
      return false
    p1 = o.position_get()
    @_remove_map(p1.asArray(), o)
    @_add_map(p2.asArray(), o)
    o.position_update()
    return true

  _key: (code)->
    if _vectors[code]
      @player.options.direction = code
      if @_move(@player, true)
        @player._bullets.forEach (b)=> @_move_bullet(b)
    if code is 'action' and !@_get(@player.position_new())
      @_add_bullet(@player.position_new().asArray(), @player.options.direction)

  _move_bullet: (bullet)->
    objects = @_get(bullet.position_new())
    if !objects
      return @_move(bullet)
    bullet.trigger "collide:#{objects[0]._type}", objects[0]

  _render_before: ->

  _render_after: ->
