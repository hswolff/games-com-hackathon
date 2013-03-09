ig.module(
	"game.entities.player"
).requires(
	"impact.entity",
	"game.entities.projectile"
).defines ->

	window.EntityPlayer = ig.Entity.extend
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
		gravityFactor: 0

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim "idle", 1, [0]

			# @body.DestroyShape @body.GetShapeList()

		update: ->

			# move left or right
			if ig.input.state("left")
				# @body.ApplyForce new b2.Vec2(-20, 0), @body.GetPosition()
			    this.currentAnim.angle -= Math.PI/5 * ig.system.tick;
			else if ig.input.state("right")
				# @body.ApplyForce new b2.Vec2(20, 0), @body.GetPosition()
			    this.currentAnim.angle += Math.PI/5 * ig.system.tick;

			# @body.SetXForm @body.GetPosition(), this.angle

			# window.body = @body

			# shoot
			if ig.input.pressed("shoot")
				x = @pos.x
				y = @pos.y

				velocity = 10
				projectile = ig.game.spawnEntity EntityProjectile, x, y,
					flip: @flip
				impulse = new b2.Vec2(Math.cos(@currentAnim.angle), Math.sin(@currentAnim.angle))
				# impulse = new b2.Vec2(-10,-10)
				window.i = impulse
				impulse.Normalize()
				impulse.Multiply(10)
				console.log impulse
				projectile.body.ApplyImpulse impulse, projectile.body.GetPosition()
				console.log projectile

			# This sets the position and angle. We use the position the object
			# currently has, but always set the angle to 0 so it does not rotate

			# move!
			@parent()

	return
