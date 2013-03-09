ig.module(
  "game.entities.projectile"
).requires(
  "plugins.box2d.entity"
).defines ->

  ProjectileSound = class extends AudioletGroup

    constructor: (audiolet, frequency) ->
      super audiolet, 0, 1

      # create core audio
      @sine = new Sine(audiolet, frequency)
      @gain = new Gain(audiolet)
      
      # create envelope
      @gainEnv = new PercussiveEnvelope(audiolet, 0, 0.1, 0.15, => @remove())
      @gainEnvMulAdd = new MulAdd(audiolet, 0)

      # connect envelope
      @gainEnv.connect(@gainEnvMulAdd)
      @gainEnvMulAdd.connect(@gain, 0, 1)

      # route core audio
      @sine.connect(@gain)
      @gain.connect(@outputs[0])

  ProjectileSoundManager = class

    constructor: ->
      @audiolet = new Audiolet
      @scale = new MajorScale()
      @index = 9

    add: _.throttle(->
      degree = @index--
      freq = @scale.getFrequency(degree, 16.352, 4)
      sound = new ProjectileSound(@audiolet, freq)
      sound.connect(@audiolet.output)
      @index = 9 if not @index
    , 200)

  projectileSoundManager = new ProjectileSoundManager


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
      projectileSoundManager.add()

  return