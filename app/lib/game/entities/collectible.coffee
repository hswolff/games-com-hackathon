ig.module(
	"game.entities.collectible"
).requires(
	"impact.entity"
).defines ->

	window.EntityCollectible = ig.Entity.extend
		size:
			x: 16
			y: 16

		type: ig.Entity.TYPE.A

		checkAgainst: ig.Entity.TYPE.A 

		gravityFactor: 0

		#collides: ig.Entity.COLLIDES.NEVER

		init: (x, y, settings) ->
			@animSheet = do ->
				color = ['red', 'orange', 'blue'][Math.floor(Math.random() * 3)]
				new ig.AnimationSheet("img/sprinkle-#{color}.png", 16, 16)	

			@addAnim "idle", 1, [0]
			#@addAnim "collected", 1, [0]
			
			@parent x, y, settings	
		

		check: (other) ->
			return if @collected
			@collected = yes
			collectibleSoundManager.add()
			# @TODO: Somehow fire an event here that
			# updates global/user state.

		update: ->
			if @collected 
				# @TODO: need anim frame for when you collect
				@currentAnim = @anims.collected 
			else 
				@currentAnim = @anims.idle

	class CollectibleSound extends AudioletGroup

    constructor: (audiolet, frequency) ->
      super audiolet, 0, 1

      # create core audio
      @sine = new Saw(audiolet, frequency)
      @gain = new Gain(audiolet)
      @vol = new Gain(audiolet, 0.2)
      
      # create envelope
      @gainEnv = new PercussiveEnvelope(audiolet, 0, 0.1, 0.15, => @remove())
      @gainEnv.connect(@gain, 0, 1)

      # route core audio
      @sine.connect(@gain)
      @gain.connect(@vol)
      @vol.connect(@outputs[0])

  class CollectibleSoundManager

    constructor: ->
      @scale = new MajorScale()
      @index = 16

    add: _.throttle(->
      return if not @index
      degree = @index--
      freq = @scale.getFrequency(degree, 2, 4)
      sound = new CollectibleSound(window.audiolet, freq)
      sound.connect(window.audiolet.output)
    , 200)

  collectibleSoundManager = new CollectibleSoundManager