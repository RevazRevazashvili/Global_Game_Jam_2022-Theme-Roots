"""
This script controls the player character.
"""
extends KinematicBody2D

enum {
	IDLE,
	RUNNING,
	FLYING,
	HIDING,
	SHOOTING,
	JUMP,
	DOUBLE_JUMP,
	IN_AIR,
	LAND,
	DIE
}

var state = IDLE

const JUMP_FORCE = 1000			# Force applied on jumping
const MOVE_SPEED = 400			# Speed to walk with
const GRAVITY = 60				# Gravity applied every second
const MAX_SPEED = 4000			# Maximum speed the player is allowed to move
const FRICTION_AIR = 0.965		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground
const CHAIN_LENGHT = 600		# Maximum lenght that chain can extend to
const CHAIN_PULL = 80
const FALL_DAMAGE = true
const FATAL_FALL_SPEED = 1000

const HIDE_OPACITY = 0.2		# Determines the opacity of player sprite when hiding

onready var last_checkpoint = self.global_position

var velocity = Vector2(0,0)		# The velocity of the player (kept over time)
var chain_velocity := Vector2(0,0)
var can_jump = false			# Whether the player used their air-jump
var has_jumped = false			# To fix not double jumping after falling off a platform
var is_hiding = false
var is_facing_right = true
var is_dead = false
var x_scale

var was_on_ground = true
var was_fatal_falling = true

func _ready():
	x_scale = $Sprite.scale.x
	$right_run_particles.emitting = false
	$left_run_particles.emitting = false


func _on_Checkpoint_Detector_area_entered(area):
	last_checkpoint = area.global_position


func _on_Enemy_detector_body_entered(body):
	print(body.is_in_group("enemy"))
	if(is_hiding): return
	state = DIE
	$Sprite.play("Death")
	is_dead = true
	


func _input(event: InputEvent) -> void:
	if(state == DIE): return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT && !is_hiding:
			if event.pressed:
			# We clicked the mouse -> shoot()
				$Chain.shoot(event.position - get_viewport().size * 0.5)
				$HookShot.play()
			else:
			# We released the mouse -> release()
				$Chain.release()


# This function is called every physics frame
func _physics_process(_delta: float) -> void:
	if(self.global_position.y >= 860):
		state = DIE
	
	# When falling off
	if(!is_on_floor() && 
	(state == RUNNING
	|| state == IDLE)
	):
		state = IN_AIR

	if(state != RUNNING):
		stop_run_particles()
	
	
	
	match state:
		IDLE :
			$Sprite.play("Idle")
		RUNNING:
			if(is_on_floor()):
				if(is_facing_right):
					$Sprite.play("Running_right")
					$right_run_particles.emitting = true
				else:
					$Sprite.play("Running_left")
					$left_run_particles.emitting = true
		IN_AIR: 
			if is_facing_right && !is_on_floor():
				$Sprite.play("In_air_right")
			else:
				$Sprite.play("In_air_left")
			if(is_on_floor()):
				if is_facing_right:
					$Sprite.play("Jump_down_left")
				else:
					$Sprite.play("Jump_down_right")
				state = LAND
				has_jumped = false
		HIDING:
			pass
		JUMP:
			if is_facing_right:
				$Sprite.play("Jump_up_right")
			else:
				$Sprite.play("Jump_up_left")
		DOUBLE_JUMP:
			if is_facing_right:
				$Sprite.play("Double Jump_right")
			else:
				$Sprite.play("Double Jump_right")
		LAND:
			if(was_fatal_falling): 
				state = DIE
				was_fatal_falling = false
				return
			if is_facing_right:
				$Sprite.play("jump_down_right")
			else:
				$Sprite.play("jump_down_left")
			has_jumped = false
		DIE:
			if(Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("restart")):
				self.position = last_checkpoint
				is_dead = false
			else: 
				is_dead = true
			
	
	
	# Walking
	var right = Input.get_action_strength("right")
	var left = Input.get_action_raw_strength("left")
	var walk = (right - left) * MOVE_SPEED
	
	
	# Falling
	velocity.y += GRAVITY
	
	manage_hook_physics(walk)
	
	apply_all_forces_without_changing_velocity(walk)
	
	manage_jump_and_air_friciton()

	
	manage_fall_damage()
	
	#manage_hiding()
	
	
	

func stop_run_particles():
	$right_run_particles.emitting = false
	$left_run_particles.emitting = false

func manage_fall_damage():
	if(!FALL_DAMAGE): return
		
	was_on_ground = is_on_floor()
	was_fatal_falling = true if velocity.y < -FATAL_FALL_SPEED else false

func manage_hook_physics(walk: float) -> void:
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
		state = IN_AIR
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity
	
	if $Chain.flying && ($Chain.tip - position).length() >= CHAIN_LENGHT:
		$Chain.release()

func apply_all_forces_without_changing_velocity(walk: float) -> void:	
	velocity.x += walk		# apply the walking
	move_and_slide(velocity, Vector2.UP)	# Actually apply all the forces
	
	if((velocity.x < -0.1 || velocity.x > 0.1) && is_on_floor()):
		state = RUNNING
	
	if (velocity.x < -0.1):
		is_facing_right = false
	elif (velocity.x > 0.1):
		is_facing_right = true
	elif(is_on_floor() && !stateIsAreal()):
		is_facing_right = true
		state = IDLE
	
	
	velocity.x -= walk		# take away the walk speed again
	# ^ This is done so we don't build up walk speed over time

func manage_jump_and_air_friciton() -> void:
	#velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	var grounded = is_on_floor()
	
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		can_jump = true 				# We refresh our air-jump
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5

	# Apply air friction
	if !grounded:
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR
		

	# Jumping
	if Input.is_action_just_pressed("jump"):
		if grounded:
			has_jumped = true
			velocity.y = -JUMP_FORCE	# Apply the jump-force
			state = JUMP
		elif !has_jumped:
			has_jumped = true
			velocity.y = -JUMP_FORCE	# Apply the jump-force
		elif can_jump:
			can_jump = false	# Used air-jump
			velocity.y = -JUMP_FORCE
			state = DOUBLE_JUMP

func manage_hiding() -> void:
	if (Input.get_action_strength("hide") > 0.01  # who knows what godot might mess up so lets go use 0.01
		&& Input.get_action_strength("left") == 0
		&& Input.get_action_strength("right") == 0
		&& is_on_floor()):
		$Sprite.modulate.a = HIDE_OPACITY
		is_hiding = true
		state = HIDING
	else:
		state = IDLE
		$Sprite.modulate.a = 1
		is_hiding = false

func _on_Sprite_animation_finished():
	match state:
		RUNNING:
			if(is_on_floor()):
				state = IDLE
			else:
				state = IN_AIR
		IN_AIR:
			if is_on_floor():
				state = LAND
		HIDING:
			pass
		JUMP:
			if(!is_on_floor()):
				state = IN_AIR
			else:
				state = LAND
		DOUBLE_JUMP:
			if(!is_on_floor()):
				state = IN_AIR
			else:
				state = LAND
		LAND:
			state = IDLE

func stateIsAreal() -> bool:
	return state == IN_AIR || state == JUMP || state == DOUBLE_JUMP


	
	
