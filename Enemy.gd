"""
This script controls the Enemy.
"""
extends KinematicBody2D

enum {
	IDLE,
	CHANGE_DIRECTION,
	WALK,
	CHASE,
	DIE,
	HIT
}


const MOVE_SPEED = 200			# Speed to walk with
const GRAVITY = 60				# Gravity applied every second
const SOUND_COUNT_MAX = 8
var sound_count = 0
var state: = WALK
var direction = -1				# Determines the direction of the enemy
var velocity = Vector2(0,0)		# The velocity of the player (kept over time)
var is_dead = false
onready var left_facing = -$Sprite.scale.x

func _ready():
	randomize()

func _on_Bullet_Detector_body_entered(body):
	body.collide(self)
	state = DIE


# This function is called every physics frame
func _physics_process(_delta: float) -> void:
	if(is_dead): return
	
	velocity.y += GRAVITY
	
	match state:
		IDLE:
			$Sprite.play("Idle")
		CHANGE_DIRECTION:
			if is_on_wall() || detect_turn_around(): direction *= -1
			else: direction *= choose([-1, 1])
			
			state = choose([IDLE, CHANGE_DIRECTION, WALK])
		WALK:
			manage_velocity_change(MOVE_SPEED)
			$Sprite.play("Walk")
		CHASE:
			$Sprite.play("Run")
		DIE:
			$Sprite.play("Die")
			self.remove_child($CollisionShape2D)
			self.remove_child($"Bullet Detector")
			is_dead = true
			$Default_sound.play()
			$Death_sound.play()
			
	adjust_direction()
			
	


func adjust_direction() -> void:
	if(direction == -1):
		$Sprite.scale.x = left_facing
	elif (direction == 1):
		$Sprite.scale.x = -left_facing
	

func look_left():
	$Sprite.scale.x = left_facing

func look_right():
	$Sprite.scale.x = -left_facing

func manage_velocity_change(walk: float) -> void:	
	velocity.x = walk*direction
	if is_on_wall() || detect_turn_around(): 
		direction *= -1
	move_and_slide(velocity, Vector2.UP)

func detect_turn_around() -> bool:
	if((not $Left.is_colliding()) and is_on_floor() and direction == -1):
		return true
	elif(not $Right.is_colliding() and is_on_floor() and direction == 1):
		return true
	else: return false

func choose(array):
	array.shuffle()
	return array[0]

func _on_Timer_timeout():
	if(state == DIE): return
	$Timer.wait_time = choose([0.5, 1, 1.5])
	if(sound_count == SOUND_COUNT_MAX):
		$Default_sound.play()
		sound_count = 0
	else:
		sound_count += 1
	state = choose([IDLE, CHANGE_DIRECTION, WALK])


func _on_right_detect_body_entered(body):
	if(state == DIE): return
	direction = 1
	adjust_direction()
	$Sprite.play("Hit")
	$Default_sound.play()
	state = HIT

func _on_left_detect_body_entered(body):
	if(state == DIE): return
	direction = -1
	adjust_direction()
	$Sprite.play("Hit")
	$Default_sound.play()
	state = HIT


func _on_Sprite_animation_finished():
	if(state == HIT): 
		state == WALK


func _on_Death_sound_finished():
	$Default_sound.stop()
