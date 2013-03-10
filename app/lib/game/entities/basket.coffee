ig.module(
	"game.entities.basket"
).requires(
	"impact.entity"
).defines ->
	window.EntityBasket = ig.Entity.extend
		type: ig.Entity.TYPE.A
		animSheet: new ig.AnimationSheet("img/basket.png", 128, 128)
		size: 
			x: 128
			y: 128

		level: null

		checkAgainst: ig.Entity.TYPE.A 

		init: (x, y, settings) ->
			@addAnim 'idle', 1, [0]
			@parent x, y, settings

		check: (other) ->
			if other instanceof EntityProjectile and @level
				ig.game.loadLevelDeferred ig.global["Level#{@level}"] 
			

