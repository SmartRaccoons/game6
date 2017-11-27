


window.o.Game = class Game extends MicroEvent

  constructor: (@options = options)->

  _render_loop: ->

  _render_before_loop: ->

  map: ->
    new window.o.ObjectCylinder({
        top: 1
        bottom: 4
        height: 5
    })

  render: ->
    @canvas = document.createElement('canvas')
    @options.container.append(@canvas)
    engine = @_engine = new BABYLON.Engine(@canvas, true)
    engine.runRenderLoop =>
      @_render_loop()
      scene.render()
    window.addEventListener 'resize', ->
      engine.resize()

    scene = @_scene = new BABYLON.Scene(engine)
    scene.registerBeforeRender @_render_before_loop.bind(@)
    scene.clearColor = new BABYLON.Color4(0, 0, 0, 0)
    @_camera = camera = new BABYLON.ArcRotateCamera("Camera", 0, 0, 100, BABYLON.Vector3.Zero(), @_scene)
    @_camera.setPosition(new BABYLON.Vector3(0, 0, -150))
    @_light = new BABYLON.HemisphericLight('Light', new BABYLON.Vector3(-40, 60, -100), @_scene)
    # scene.enablePhysics(new BABYLON.Vector3(0, -9.81, 0), new BABYLON.CannonJSPlugin())
    window.App.events.trigger('game:init', scene, engine, @_light, @_camera)

  remove: ->
    @_camera.dispose()
    @_light.dispose()
    @_scene.dispose()
    @_engine.stopRenderLoop()
    @_engine.dispose()
    @canvas.parentElement.removeChild(@canvas)
