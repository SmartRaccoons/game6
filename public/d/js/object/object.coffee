
_object_id = 0

meshes = {}
vertexes = null
_scene = null
_engine = null
_light = null
_camera = null

window.App.events.bind 'game:init', (scene, engine, light, camera)->
  _scene = scene
  _engine = engine
  _light = light
  _camera = camera
  # meshes = {}
  # for k, v of window.o.ObjectData
  #   vertex = new BABYLON.VertexData()
  #   vertex.positions = v.positions.slice()
  #   vertex.normals = v.normals.slice()
  #   vertex.indices = v.indices.slice()
  #   meshes[k] = new BABYLON.Mesh("preload_#{k}", _scene)
  #   vertex.applyToMesh(meshes[k])
  #   meshes[k].convertToFlatShadedMesh()
  #   meshes[k].isVisible = false
  # _convertToFlat = true

window.o.Object = class Object extends MicroEvent
  _color: [0, 0, 0]
  _default: {}
  constructor: (options)->
    super
    _object_id++
    @_id = _object_id
    @options = _.extend({}, @_default, options)
    @mesh = @mesh_build()
    @mesh._type = @name
    if @options.parent
      @parent = @options.parent
      if @parent.mesh
        @mesh.parent = @parent.mesh
    if @options.position
      @mesh.position = new BABYLON.Vector3(@options.position[0], @options.position[1] or 0, @options.position[2] or 0)
    if @options.color
      @_color = @options.color
      @color()
    if @options.action
      @_action(@options.action)
    if @_imposter
      @mesh.physicsImpostor = new BABYLON.PhysicsImpostor(@mesh, @_imposter, _.extend({}, {mass: 1}, @options.imposter), @scene())
    @

  _action: (action)->
    @mesh.actionManager = new BABYLON.ActionManager(@scene())
    if action.click
      @mesh.actionManager.registerAction new BABYLON.ExecuteCodeAction BABYLON.ActionManager.OnPickTrigger, action.click
    if action.mouseover
      @mesh.actionManager.registerAction new BABYLON.ExecuteCodeAction BABYLON.ActionManager.OnPointerOverTrigger, action.mouseover
    if action.mouseout
      @mesh.actionManager.registerAction new BABYLON.ExecuteCodeAction BABYLON.ActionManager.OnPointerOutTrigger, action.mouseout

  _action_remove: ->
    if not @mesh.actionManager
      return
    @mesh.actionManager.actions = []

  mesh_build: ->
    mesh = meshes[@name].clone(meshes[@name].name)
    mesh.id = @_name()
    mesh.isVisible = true
    mesh

  color: (color = @_color, alpha = 1)->
    if !@mesh.material
      @mesh.material = new BABYLON.StandardMaterial("material_#{@_name()}", @scene())
    @mesh.material.diffuseColor = new BABYLON.Color3(color[0]/255, color[1]/255, color[2]/255)
    @mesh.material.alpha = color[3] or alpha

  scene: -> _scene

  hide: -> @mesh.isVisible = false

  show: -> @mesh.isVisible = true

  godrays: ->
    new BABYLON.VolumetricLightScatteringPostProcess("godrays_#{@_name()}", 1, _camera, @mesh, 50, BABYLON.Texture.BILINEAR_SAMPLINGMODE, _engine, false)

  _name: ->
    if not @__name
      name = ['ob']
      if @name
        name.push @name
      name.push @_id
      @__name = name.join('_')
    return @__name

  remove: ->
    super
    @mesh.dispose()


window.o.ObjectSphere = class ObjectSphere extends Object
  _default: {
    segments: 5
  }
  mesh_build: ->
    BABYLON.Mesh.CreateSphere(@_name(), @options.segments, @options.diameter, @scene())


window.o.ObjectBox = class ObjectBox extends Object
  mesh_build: ->
    d = @options.dimension
    if !d[1]?
      d[1] = d[0]
    if !d[2]?
      d[2] = d[1]
    BABYLON.MeshBuilder.CreateBox(@_name(), {
      width: d[0]
      height: d[1]
      depth: d[2]
    }, @scene())


window.o.ObjectCylinder = class ObjectCylinder extends Object
  # _imposter: BABYLON.PhysicsImpostor.CylinderImpostor
  mesh_build: ->
    BABYLON.MeshBuilder.CreateCylinder(@_name(), {
      diameterTop: @options.top
      diameterBottom: @options.bottom
      height: @options.height
    }, @scene())
