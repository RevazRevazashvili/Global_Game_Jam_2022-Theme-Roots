extends Label


func _ready():
	pass



func _process(delta):
	if(get_parent().get_parent().get_parent().is_endgame()):
		visible = true
	else:
		visible = false

