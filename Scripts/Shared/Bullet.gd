extends KinematicBody2D

export var smokeScene : PackedScene
export var impactScene : PackedScene


var speed = 1500
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_parent().global_position


func _physics_process(delta):
	var collisionResult = move_and_collide(direction * speed * delta)
	
	if collisionResult:
		collide(collisionResult)
		

func collide(collisionResult) -> void:
	# Smoke particles
	var smoke = smokeScene.instance() as Particles2D
	get_parent().get_parent().add_child(smoke)
	smoke.global_position = collisionResult.position
	smoke.rotation = (-direction).angle()
	
	# Impact particles
	var impact = impactScene.instance() as Node2D
	get_parent().get_parent().add_child(impact)
	impact.global_position = collisionResult.position
	impact.rotation = (direction).angle()
	
	queue_free()

