extends Node



var player

func _ready():
	player = get_node("/root/Main").get_node("/root/Main/Player")
