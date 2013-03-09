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
			# @TODO: Somehow fire an event here that
			# updates global/user state.

		update: ->
			if @collected 
				# @TODO: need anim frame for when you collect
				@currentAnim = @anims.collected 
			else 
				@currentAnim = @anims.idle
