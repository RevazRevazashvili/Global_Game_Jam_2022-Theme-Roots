extends HBoxContainer


func _process(delta):
	$TextureProgress.value = Game.player.hp

