extends AnimatedSprite


const SPROUT_TIME = 10
var just_planted = false
var started_sprouting = false
func _process(delta):
	if(just_planted):
		$Timer.start(SPROUT_TIME)
		just_planted = false
		started_sprouting = true
		$AudioStreamPlayer2D.play()
	

func _on_Timer_timeout():
	if(started_sprouting):
		$TileMap.visible = true
		$TileMap.get_node("AnimationPlayer").play("Fade_In")
		started_sprouting = false


func _on_AnimationPlayer_animation_finished(anim_name):
	$TileMap.get_node("AnimationPlayer").stop()
