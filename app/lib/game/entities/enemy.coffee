ig.module(
	"game.entities.enemy"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityEnemy = ig.Box2DEntity.extend
		size:
			x: 32
			y: 32

		offset:
			x: 4
			y: 2

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("img/fly.png", 32, 32)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'idle', 1, [0] 

			@currentAnim.flip.x = yes

			@t1 = 0
			@t2 = 0
			@up = no

			@position = new ig.Timer()

		distance: 15
		duration: 0.86

		updateCurrentPosition: ->
			if @position.delta() > @duration
				@position.reset()
				@invertPosition = !@invertPosition
			positionFromPower = (@distance*2) * (@position.delta()/@duration)
			if @invertPosition
				@currentPower = positionFromPower
			else
				@currentPower = (@distance*2) - positionFromPower

		update: ->
			@parent()
			@updateCurrentPosition()
			if not @invertPosition
				@body.SetXForm(new b2.Vec2(@body.GetPosition().x, @body.GetPosition().y - 0.1), 0)
			else
				@body.SetXForm(new b2.Vec2(@body.GetPosition().x, @body.GetPosition().y + 0.1), 0)

	return
