extends Node2D


export var bulletScene: PackedScene

var camera_shake_intensity = 10.0
var camera_shake_duration = 0.02


func _ready():
	pass 


func _unhandled_input(event):
	if(event.is_action_pressed("fire") && !Game.player.is_dead):
		Shake.shake(camera_shake_intensity, camera_shake_duration)
		$Bullet.play()
		var bullet = bulletScene.instance() as Node2D
		get_parent().get_parent().add_child(bullet)
		bullet.global_position = self.global_position
		bullet.direction = (get_global_mouse_position() - self.global_position).normalized()
		bullet.rotation = bullet.direction.angle()
		


