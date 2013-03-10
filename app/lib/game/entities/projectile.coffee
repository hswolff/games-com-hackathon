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
      inBasket = false
      baskets = ig.game.getEntitiesByType(EntityBasket)
      for basket in baskets
        if !@killed and @touches(basket)
          basket.currentAnim = basket.anims.close.rewind()
          ig.game.stats.baskets++
          inBasket = true

      @parent()

      muffins = ig.game.getEntitiesByType(EntityProjectile)
      if muffins.length is 0 and ig.game.stats.attempts is 0
        ig.game.trigger('finishLevel', ig.game.stats)

      unless inBasket
        ig.game.spawnEntity(EntityDeathExplosion, this.pos.x, this.pos.y )


  window.EntityDeathExplosion = ig.Entity.extend(
    lifetime: 1
    callBack: null
    particles: 25
    init: (x, y, settings) ->
      @parent x, y, settings
      i = 0

      while i < @particles
        ig.game.spawnEntity EntityDeathExplosionParticle, x, y,
          colorOffset: (if settings.colorOffset then settings.colorOffset else 0)

        i++
      @idleTimer = new ig.Timer()

    update: ->
      if @idleTimer.delta() > @lifetime
        @kill()
        @callBack()  if @callBack
        return
  )
  EntityDeathExplosionParticle = ig.Entity.extend(
    size:
      x: 23
      y: 23

    maxVel:
      x: 160
      y: 200

    lifetime: 2
    fadetime: 1
    bounciness: 0
    vel:
      x: 200
      y: 800

    friction:
      x: 100
      y: 0

    collides: ig.Entity.COLLIDES.LITE
    colorOffset: 0
    totalColors: 15
    animSheet: new ig.AnimationSheet("img/muffin-giblets.png", 23, 23)
    init: (x, y, settings) ->
      @parent x, y, settings
      frameID = Math.round(Math.random() * @totalColors) + (@colorOffset * (@totalColors + 1))
      @addAnim "idle", 0.2, [frameID]
      @vel.x = (Math.random() * 2 - 1) * @vel.x
      @vel.y = (Math.random() * 2 - 1) * @vel.y
      @idleTimer = new ig.Timer()

    update: ->
      if @idleTimer.delta() > @lifetime
        @kill()
        return
      @currentAnim.alpha = @idleTimer.delta().map(@lifetime - @fadetime, @lifetime, 1, 0)
      @parent()
  )



  
  return