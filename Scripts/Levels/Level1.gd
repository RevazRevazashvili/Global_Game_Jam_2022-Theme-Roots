extends Node2D

export (NodePath) var _plant_count
onready var plant_count:Label = get_node(_plant_count)

const ALL_PLANTERS = 20
const REQUIRED_TO_PASS = 10

var planted = 0

func _ready():
	update_plant_counter()


func planted():
	planted += 1
	update_plant_counter()


func update_plant_counter():
	plant_count.set_text("Planted " + str(planted) + "/" + str(REQUIRED_TO_PASS))


func is_endgame():
	return planted >= REQUIRED_TO_PASS

