extends PlayerState

export (NodePath) var _animation_player
onready var animation_player:AnimatedSprite = get_node(_animation_player)

export (NodePath) var _right_run_particles
onready var right_run_particles:Particles2D = get_node(_right_run_particles)

export (NodePath) var _left_run_particles
onready var left_run_particles:Particles2D = get_node(_left_run_particles)

func enter(_msg := {}):
	change_run_direction()

func handle_input(_event: InputEvent) -> void:
	player._handle_hook_input(_event)

func update(delta: float):
	change_run_direction()

func physics_update(delta: float):
	if !player.is_on_floor():
		player.stop_particle_emission()
		state_machine.transition_to("Air")
		return
	
	handle_movement_with_gravity()
	
	clamp_velocity_and_apply_friction()
	
	player.manage_hook_physics(delta)
	
	state_transition_logic()


func state_transition_logic():
	if player.is_dead:
		state_machine.transition_to("Die")
	elif Input.is_action_just_pressed("jump"):
		player.stop_particle_emission()
		state_machine.transition_to("Air", {jumped = true})
	elif Input.is_action_just_pressed("hide"):
		player.stop_particle_emission()
		state_machine.transition_to("Hide")
	elif is_zero_approx(player._get_input_direction()):
		player.stop_particle_emission()
		state_machine.transition_to("Idle")


func change_run_direction():
	if(is_zero_approx(player._get_input_direction())):
		player.stop_particle_emission()
	elif(player._get_input_direction() > 0):
		animation_player.play("Running_right")
		player.emit_right_run_particles()
	else :
		animation_player.play("Running_left")
		player.emit_left_run_particles()

func handle_movement_with_gravity():
	# gravity
	player.velocity.y += player.GRAVITY
	
	var walk = player._get_input_direction()*player.MOVE_SPEED
	
	player.velocity.x += walk
	
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)	# Actually apply all the forces
	
	player.velocity.x -= walk
	
	
	

func clamp_velocity_and_apply_friction():
	# clamp max velocity
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	
	player.velocity.x *= player.FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
	if player.velocity.y >= 5:		# Keep the y-velocity small such that
		player.velocity.y = 5		# gravity doesn't make this number huge
	
