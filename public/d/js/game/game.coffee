window.o.Game = class Game extends MicroEvent
  constructor: ->
    super
    @_rendered = false
    @canvas = document.createElement('canvas')
    @_engine = new BABYLON.Engine(@canvas, true)
    window.addEventListener 'resize', => @_engine.resize()
    check_move = (code)->
      for key, codes of {
        left: [37, 65]
        up: [38, 87]
        right: [39, 68]
        down: [40, 83]
        action: [32]
      }
        if codes.indexOf(code) > -1
          return key
      return false
    window.addEventListener 'keyup', (e)=>
      if !@_map
        return
      key = check_move(e.keyCode)
      if !key
        return
      @_map._key(key)
    @

  render: (options)->
    options.container.append(@canvas)
    @_engine.resize()
    @_scene = new BABYLON.Scene(@_engine)
    @_scene.clearColor = new BABYLON.Color4(0, 0, 0, 0)
    @_camera = new BABYLON.ArcRotateCamera("Camera", 0, 0, 100, BABYLON.Vector3.Zero(), @_scene)
    @_camera.setPosition(new BABYLON.Vector3(0, 0, -30))
    @_light = new BABYLON.HemisphericLight('Light', new BABYLON.Vector3(-40, -60, -100), @_scene)
    window.App.events.trigger('game:init', @_scene, @_engine, @_light, @_camera)
    # @_scene.enablePhysics(new BABYLON.Vector3(0, 0, 0), new BABYLON.CannonJSPlugin())
    @_map = new window.o.GameMap()
    @_engine.runRenderLoop =>
      @_map._render_before()
      @_scene.render()
      @_map._render_after()
    @_rendered = true

  clear: ->
    @unbind()
    if not @_rendered
      return
    @_rendered = false
    @_map.remove()
    @_camera.dispose()
    @_light.dispose()
    @_scene.dispose()
    @_engine.stopRenderLoop()
    @canvas.parentElement.removeChild(@canvas)
