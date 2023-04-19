class_name Player
extends KinematicBody2D


const JUMP_FORCE = 1000			# Force applied on jumping
const MOVE_SPEED = 400			# Speed to walk with
const MOVE_ACCEL = 200			# Movement acceleration
const GRAVITY = 60				# Gravity applied every second
const MAX_SPEED = 4000			# Maximum speed the player is allowed to move
const FRICTION_AIR = 0.965		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground
const CHAIN_LENGHT = 600		# Maximum lenght that chain can extend to
const CHAIN_PULL = 80
const AIR_JUMP_AMOUNT = 2		# Amount of jumps player is allowed before they touch ground

const FALL_DAMAGE = true
const FATAL_FALL_SPEED = 1000

const HIDE_OPACITY = 0.2		# Determines the opacity of player sprite when hiding

export (NodePath) var _timer
onready var timer:Timer = get_node(_timer)

export (NodePath) var _chain
onready var chain:Chain = get_node(_chain)

export (NodePath) var _plant
onready var plant:AnimatedSprite = get_node(_plant)

export (NodePath) var _label
onready var label:Label = get_node(_label)


onready var last_checkpoint = self.global_position

var velocity = Vector2(0,0)		# The velocity of the player (kept over time)

var chain_velocity := Vector2(0,0)

var is_facing_right = true

var planting_zone = null

var jump_count = 2

var is_hiding = false

var is_dead = false

var hp = 100

var is_hit = false

var end_game_label_shown = false

func _on_EnemyDetection_body_entered(body):
	$Chain.release()
	hp = hp - 10
	Shake.shake(10, 0.2)
	if hp <= 0 : is_dead = true
	
	
	
func _on_EnemyDetection_area_entered(area):
	_set_new_checkpoint(area.position)

func _ready():
	$Plant.visible = false


func _process(delta):
	if(Input.is_action_just_pressed("restart")):
		global_position = last_checkpoint
	if(!is_dead && hp < 100): hp += 0.5 * delta
	
	if(global_position.y > 400):
		$Chain.release()
		is_dead = true
		hp = 0
		return
	
	if(get_parent().is_endgame() && !end_game_label_shown):
		label.visible = true
		end_game_label_shown = true
		$Timer2.start(10)
		
	


func _handle_hook_input(event: InputEvent) -> void:
	if(is_dead): return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT && !is_hiding:
			if event.pressed:
			# We clicked the mouse -> shoot()
				$Chain.shoot(event.position - get_viewport().size * 0.5)
			else:
			# We released the mouse -> release()
				$Chain.release()
				
	if Input.is_action_just_pressed("plant") && planting_zone:
		$AudioStreamPlayer2D.play()
		var sapling = $Plant.duplicate()
		get_parent().add_child(sapling)
		sapling.global_position = planting_zone.global_position
		sapling.visible = true
		sapling.just_planted = true
		sapling.play("default")
		get_parent().planted()
		last_checkpoint = global_position
		planting_zone.queue_free()
		if (hp<50):
			hp = hp + 50
		else:
			hp = 100

func _reset():
	hp = 100
	is_dead = false
	$Chain.release()
	position = last_checkpoint

func _get_input_direction():
	var right = Input.get_action_strength("right")
	var left = Input.get_action_raw_strength("left")
	var direction = right - left
	
	if (direction < 0):	
		is_facing_right = false
	elif (direction > 0):
		is_facing_right = true
	
	return direction

func manage_hook_physics(delta):
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != _get_input_direction():
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
		
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	
	if $Chain.flying && ($Chain.tip - position).length() >= CHAIN_LENGHT:
		$Chain.release()
	
	velocity += chain_velocity

func emit_right_run_particles():
		$right_run_particles.emitting = true
func emit_left_run_particles():
		$left_run_particles.emitting = true
func stop_particle_emission():
	$left_run_particles.emitting = false
	$right_run_particles.emitting = false

func _set_new_checkpoint(new_pos):
	last_checkpoint = new_pos
	
	
func _on_Area2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	$Label.visible = true
	planting_zone = area


func _on_Area2D_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	$Label.visible = false
	planting_zone = null


func _on_Timer2_timeout():
	label.visible = false
