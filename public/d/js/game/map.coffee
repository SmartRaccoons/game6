class Empty extends window.o.ObjectBox
  _imposter: BABYLON.PhysicsImpostor.BoxImpostor
  _default: {
    dimension: [0.8, 0.2, 0.8]
    imposter: {
      mass: 0
      restitution: 0.9
    }
  }


class Object extends window.o.ObjectBox
  _imposter: BABYLON.PhysicsImpostor.BoxImpostor
  _default: {
    dimension: [0.9, 0.8, 0.9]
    color: [255, 0, 0]
    imposter: {
      mass: 2
      restitution: 0.9
    }
  }



window.o.GameMap = class Map extends MicroEvent
  constructor: ->
    for i in [-4..4]
      for j in [-4..4]
        new Empty({position: [i, 0, j]})

    @object = new Object({position: [0, 3, 0]})

  _key: ->
    @object.mesh.physicsImpostor.setLinearVelocity(new BABYLON.Vector3(0, 10, 0))

  _render_before: ->

  _render_after: ->
