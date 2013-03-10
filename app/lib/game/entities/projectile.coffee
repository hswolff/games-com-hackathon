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
    restitution: 0.8

    animSheet: new ig.AnimationSheet("img/muffin.png", 64, 64)

    init: (x, y, settings) ->
      @parent x, y, settings
      @addAnim "idle", 1, [0]
      @currentAnim.flip.x = settings.flip
      @soundManager = new ProjectileSoundManager
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
          ig.game.stats.baskets++

      @parent()

      muffins = ig.game.getEntitiesByType(EntityProjectile)
      if muffins.length is 0 and ig.game.stats.attempts is 0
        ig.game.trigger('finishLevel', ig.game.stats)


    collideTile: ->
      @soundManager.add()


  class ProjectileSound extends AudioletGroup

    constructor: (audiolet, frequency) ->
      super audiolet, 0, 1

      # create core audio
      @sine = new Triangle(audiolet, frequency)
      @gain = new Gain(audiolet)
      
      # create envelope
      @gainEnv = new PercussiveEnvelope(audiolet, 0, 0.1, 0.15, => @remove())
      @gainEnv.connect(@gain, 0, 1)

      # route core audio
      @sine.connect(@gain)
      @gain.connect(@outputs[0])

  class ProjectileSoundManager

    constructor: ->
      @audiolet = window.audiolet
      @scale = new MajorScale()
      @index = 16

    add: _.throttle(->
      return if not @index
      degree = @index--
      freq = @scale.getFrequency(degree, 2, 4)
      sound = new ProjectileSound(@audiolet, freq)
      sound.connect(@audiolet.output)
    , 200)
  
  return