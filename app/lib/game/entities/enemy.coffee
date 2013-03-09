ig.module(
	"game.entities.enemy"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityEnemy = ig.Box2DEntity.extend
		size:
			x: 8
			y: 14

		offset:
			x: 4
			y: 2

		type: ig.Entity.TYPE.B
		checkAgainst: ig.Entity.TYPE.A
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!

		animSheet: new ig.AnimationSheet("media/enemy.png", 16, 24)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'move', 0.05, [1,2] 

			@timer = new ig.Timer(0.5)

			@currentAnim.flip.x = yes

		check: (other) ->
			console.log 'yes'


		update: ->
			@parent()

			if @timer.delta() >= 1
				@timer.reset()
			else if @timer.delta() > 0.5 and @timer.delta() < 1
				# @currentAnim.flip.x = no
				@body.ApplyImpulse new b2.Vec2(0, -1), @body.GetPosition()
			else
				@body.ApplyImpulse new b2.Vec2(0, 1), @body.GetPosition()


	return
