ig.module(
  "game.entities.projectile"
).requires(
  "plugins.box2d.entity"
).defines ->

  window.EntityProjectile = ig.Box2DEntity.extend
    size:
      x: 8
      y: 4

    type: ig.Entity.TYPE.A
    checkAgainst: ig.Entity.TYPE.B
    collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
    restitution: 0.8

    animSheet: new ig.AnimationSheet("media/projectile.png", 8, 4)

    init: (x, y, settings) ->
      @parent x, y, settings
      @addAnim "idle", 1, [0]
      @currentAnim.flip.x = settings.flip
      return

    collideTile: ->
      window.bloop.trigger.trigger.setValue(1)

  return