extends Node


export var bulletScene: PackedScene

onready var enemySpawner = false

func _ready():
	pass 	

func shoot():
	var bullet = bulletScene.instance() as Node2D
	bullet.speed = 500
	get_parent().get_parent().add_child(bullet)
	bullet.global_position = get_parent().global_position
	bullet.direction = (Game.player.global_position - get_parent().global_position + Vector2(randf()*80, randf()*80)).normalized()
	bullet.rotation = bullet.direction.angle()


