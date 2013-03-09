ig.module(
	"game.entities.exit"
).requires(
	"impact.entity"
).defines ->
	window.EntityExit = ig.Entity.extend
		_wmDrawBox: yes

		_wmBoxColor: 'rgba(0, 0, 255, 0.7)'

		type: ig.Entity.TYPE.A

		size: 
			x: 8
			y: 16

		level: null

		checkAgainst: ig.Entity.TYPE.A 

		update: ->

		check: (other) ->
			if other instanceof EntityProjectile and @level
				ig.game.loadLevelDeferred ig.global["Level#{@level}"] 
			

