ig.module(
	"game.entities.player"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityPlayer = ig.Box2DEntity.extend
		size:
			x: 8
			y: 14

		offset:
			x: 4
			y: 2

		type: ig.Entity.TYPE.A
		checkAgainst: ig.Entity.TYPE.NONE
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!

		animSheet: new ig.AnimationSheet("media/player.png", 16, 24)
		flip: false

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim "idle", 1, [0]
			@addAnim "jump", 0.07, [1, 2]

		update: ->

			# move left or right
			if ig.input.state("left")
				@body.ApplyForce new b2.Vec2(-20, 0), @body.GetPosition()
				@flip = true
			else if ig.input.state("right")
				@body.ApplyForce new b2.Vec2(20, 0), @body.GetPosition()
				@flip = false

			# jetpack
			if ig.input.state("jump")
				@body.ApplyForce new b2.Vec2(0, -30), @body.GetPosition()
				@currentAnim = @anims.jump
			else
				@currentAnim = @anims.idle

			# shoot
			if ig.input.pressed("shoot")
				x = @pos.x + ((if @flip then -6 else 6))
				y = @pos.y + 6
				ig.game.spawnEntity EntityProjectile, x, y,
					flip: @flip

			@currentAnim.flip.x = @flip

			# This sets the position and angle. We use the position the object
			# currently has, but always set the angle to 0 so it does not rotate
			@body.SetXForm @body.GetPosition(), 0

			# move!
			@parent()

	window.EntityProjectile = ig.Box2DEntity.extend
		size:
			x: 8
			y: 4

		type: ig.Entity.TYPE.A
		checkAgainst: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!

		animSheet: new ig.AnimationSheet("media/projectile.png", 8, 4)

		init: (x, y, settings) ->
			@parent x, y, settings
			@addAnim "idle", 1, [0]
			@currentAnim.flip.x = settings.flip
			velocity = ((if settings.flip then -10 else 10))
			@body.ApplyImpulse new b2.Vec2(velocity, 0), @body.GetPosition()
			return

		collideTile: ->
			console.log 'projectile hit wall'

	return
