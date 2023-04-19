extends RigidBody2D

const MAX_THRUST = 100
const MAX_SPEED = 100
const SHOOT_COOLDOWN = 2
const BULLET_RANGE = 400
const EXPLOSION_TIME = 0.4
const SHOOT_ANIM_TIME = 0.6
const MAX_ACTIVATION_DISTANCE = 1200

var camera_shake_intensity = 20.0
var camera_shake_duration = 0.02

var sleep = false
var alive = true
var idle = true

var target_rotation = 0
var rotation_speed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$Gun.enemySpawner = true
	$ShootTimer.start(SHOOT_COOLDOWN)

func _integrate_forces(state):
	
	if(!forces_can_be_applyed()): return
	
	var delta = state.get_step()
	
	
	# get closest
	var closest_collision = null
	$rays.rotation += delta*11*PI
	for ray in $rays.get_children():
		if ray.is_colliding():
			var collision_point = ray.get_collision_point() - global_position
			if closest_collision == null:
				closest_collision = collision_point
			if collision_point.length() < closest_collision.length():
				closest_collision = collision_point
	
	# doge
	if closest_collision:
		var normal = -closest_collision.norm
		var dodge_direction = 1
		if randf() < 0.5:
			dodge_direction = -1
		state.linear_velocity += normal * MAX_THRUST * 2 * delta
		state.linear_velocity += normal.rotated(PI/2 * dodge_direction) * MAX_SPEED * delta
	
		
	
	# go towards player
	var distance_to_player = global_position.distance_to(Game.player.global_position)
	var vector_to_player = (Game.player.global_position - global_position).normalized()
	
	
	if distance_to_player > 180:
		# move to player
		state.linear_velocity += vector_to_player * MAX_THRUST * delta
	else:
		# move away from player
		state.linear_velocity += -vector_to_player * MAX_THRUST * delta
	
	# clamp max speed
	if state.linear_velocity.length() > MAX_SPEED:
		state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED
		
	var target_pos = Game.player.global_position
	look_at(target_pos)
	
	var angle = (target_pos - position).angle()
	
	if(self.global_position.x < Game.player.global_position.x): 
		scale.y = 1
	else: 
		scale.y = -1

	

func _process(delta):
	if(idle):
		$Sprite.play("Idle")
	



func _physics_process(delta):
	if not $VisibilityEnabler2D.is_on_screen():
		return
	

func forces_can_be_applyed():
	if(!alive): return false
	if(sleep): return false
	if(Game.player.is_dead): return false
	var distance_to_player = global_position.distance_to(Game.player.global_position)
	if(distance_to_player > MAX_ACTIVATION_DISTANCE):
		return false
	return true


func _on_VisibilityEnabler2D_viewport_exited(viewport):
	idle = true
	sleep = true



func _on_Area2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	alive = false
	$ExplosionWave.set_deferred("monitorable", true)
	print($ExplosionWave.monitorable)
	var shockwave = $ExplosionWave.get_child(0) as CollisionShape2D
	var plants_ratio = get_parent().planted/get_parent().REQUIRED_TO_PASS
	shockwave.scale *= plants_ratio
	$Sprite.visible = false
	#linear_velocity = Vector2(0,0)
	$AudioStreamPlayer2D.play()
	$Particles2D.emitting = true
	Shake.shake(camera_shake_intensity, camera_shake_duration)


func _on_Shoot_Timer_timeout():
	shoot()



func shoot():
	$ShootTimer.wait_time = SHOOT_COOLDOWN * (1 + rand_range(-0.25, 0.25))
	$ShootTimer.start()
	
	if(!forces_can_be_applyed()): return
	$ShootSound.play()
	
	if(((Game.player.global_position - self.global_position)).length() > BULLET_RANGE ):
		return
	
	idle = false
	$Sprite.play("Shoot")
	$AnimTimer.start(SHOOT_ANIM_TIME)
	$Gun.shoot()
	



func _on_Timer_timeout():
	queue_free()


func _on_AnimTimer_timeout():
	idle = true


func _on_SleepTimer_timeout():
	linear_velocity = Vector2(0,0)
	$AudioStreamPlayer2D.play()
	$Particles2D.emitting = true
	$Timer.start(EXPLOSION_TIME)
	Shake.shake(camera_shake_intensity, camera_shake_duration)
