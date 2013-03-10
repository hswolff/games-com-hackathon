ig.module(
	"game.entities.trampoline"
).requires(
	"impact.entity",
	"plugins.box2d.entity"
).defines ->

	window.EntityTrampoline = ig.Box2DEntity.extend
		size:
			x: 50
			y: 50

		type: ig.Entity.TYPE.B
		collides: ig.Entity.COLLIDES.NEVER # Collision is already handled by Box2D!
		static: true
		animSheet: new ig.AnimationSheet("media/evil-enemy.png", 16, 24)

		init: (x, y, settings) ->
			@parent x, y, settings

			# Add the animations
			@addAnim 'idle', 1, [0] 

		update: -> @parent()

		collideWith: (entity) -> 
			# impulse = new b2.Vec2 -100, -100
			# entity.body.ApplyTorque 0.45
			# entity.angle = @angleTo(entity)
			if @pos.x - entity.pos.x > 0 # and @pos.y - entity.pos.y > 0
				impulse = new b2.Vec2(Math.cos(-entity.currentAnim.angle), Math.sin(-entity.currentAnim.angle))
				impulse.Multiply(100)
				entity.body.ApplyImpulse impulse, entity.body.GetPosition()

	return
