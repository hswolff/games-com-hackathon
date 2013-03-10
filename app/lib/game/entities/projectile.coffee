ig.module(
  "game.entities.projectile"
).requires(
  "plugins.box2d.entity"
).defines ->

  window.EntityProjectile = ig.Box2DEntity.extend
    size:
      x: 55
      y: 55

    type: ig.Entity.TYPE.A
    checkAgainst: ig.Entity.TYPE.B
    collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
    restitution: 0.5

    animSheet: new ig.AnimationSheet("img/muffin.png", 64, 64)

    init: (x, y, settings) ->
      @parent x, y, settings
      @addAnim "idle", 1, [0]
      @currentAnim.flip.x = settings.flip
      @body.AllowSleeping true
      return

    update: ->
      return @kill() if @body.IsSleeping() or @killed
      @parent()

    createBody: ->
      @parent()
      @body.m_angularDamping = 5

    kill: ->
      baskets = ig.game.getEntitiesByType(EntityBasket)
      for basket in baskets
        if @touches(basket)
          basket.currentAnim = basket.anims.close.rewind()
          ig.game.stats.baskets++

      @parent()

      muffins = ig.game.getEntitiesByType(EntityProjectile)
      if muffins.length is 0 and ig.game.stats.attempts is 0
        ig.game.trigger('finishLevel', ig.game.stats)
  
  return