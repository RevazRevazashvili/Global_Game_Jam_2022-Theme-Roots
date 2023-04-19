extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _process(delta):
	if(Game.player.global_position.y > 370): return
	if(Game.player.is_dead): visible = true
	else: visible = false
