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

		animSheet: new ig.AnimationSheet("img/blueberry.png", 32, 32)

		init: (x, y, settings) ->
			@addAnim "idle", 1, [0]
			#@addAnim "collected", 1, [0]
			@parent x, y, settings	
		

		check: (other) ->
			return if @collected
			@collected = yes
			soundManager.add()
			ig.game.trigger 'collect', @

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
			@sine = new Triangle(audiolet, frequency)
			@gain = new Gain(audiolet)
			@vol = new Gain(audiolet, 0.5)

			# create envelope
			@gainEnv = new PercussiveEnvelope(audiolet, 0, 0.1, 0.15, => @remove())
			@gainEnv.connect(@gain, 0, 1)

			# route core audio
			@sine.connect(@gain)
			@gain.connect(@vol)
			@vol.connect(@outputs[0])

	class CollectibleSoundManager

		# d3, f3, g3, a3, g3, f3. like the bass
		constructor: ->
			@scale = [136.8, 174.6, 196, 220]
			@index = 3

		add: _.throttle(->
			freq = @scale[@index--]
			sound = new CollectibleSound(window.audiolet, freq)
			sound.connect(window.audiolet.output)
			@index = 3 if not @scale[@index]
		, 200)

	soundManager = new CollectibleSoundManager