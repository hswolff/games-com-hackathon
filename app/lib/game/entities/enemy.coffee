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

		update: ->
			@parent()

			if @up
				@t1 += 1
				@body.SetXForm(new b2.Vec2(@body.GetPosition().x, @body.GetPosition().y + 0.2), 0)
				if @t1 is 15
					@up = no
					@t1 = 0
			else
				@t2 += 1
				@body.SetXForm(new b2.Vec2(@body.GetPosition().x, @body.GetPosition().y - 0.2), 0)
				if @t2 is 15
					@up = yes
					@t2 = 0

	return
