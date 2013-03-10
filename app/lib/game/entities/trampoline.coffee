ig.module(
	"game.entities.trampoline"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityTrampoline = ig.Box2DEntity.extend
		size:
			x: 64
			y: 64

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("img/bumper.png", 64, 64)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'idle', 1, [0] 

		update: -> @parent()

		collideWith: (entity) -> 
			if @pos.x - entity.pos.x > 0
				impulse = new b2.Vec2(Math.cos(-entity.currentAnim.angle), Math.sin(-entity.currentAnim.angle))
				impulse.Multiply(100)
				entity.body.ApplyImpulse impulse, entity.body.GetPosition()
			else
				entity.body.SetLinearVelocity new b2.Vec2(0, 0)

	return
