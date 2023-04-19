extends PlayerState

export (NodePath) var _animation_player
onready var animation_player:AnimatedSprite = get_node(_animation_player)

func enter(_msg := {}):
	if(player.jump_count >= 1):
		player.jump_count = 1
	
	player.stop_particle_emission()
	
	change_slide_direction()

func handle_input(_event: InputEvent) -> void:
	player._handle_hook_input(_event)

func update(_delta: float):
	#change_slide_direction()
	pass

func physics_update(delta: float):
	if !player.is_on_wall():
		state_machine.transition_to("Air")
	
	handle_wall_slide_movement();
	
	player.manage_hook_physics(delta)
	
	state_transition_logic()

func handle_wall_slide_movement():
	# gravity
	player.velocity.y += player.GRAVITY*0.2;
	
	if player.velocity.y > 300:
		player.velocity.y = 300
	
	if player.velocity.y < 0:
		player.velocity.y = 0
	
	var lateral_movement = player._get_input_direction()*player.MOVE_SPEED
	
	player.velocity.x += lateral_movement
	
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)	# Actually apply all the forces
	
	player.velocity.x -= lateral_movement

func change_slide_direction():
	if(player._get_input_direction() > 0):
		animation_player.play("WallSlide_right")
	else :
		animation_player.play("WallSlide_left")	#animation_player.play("right_wall_slide")
	#else :
	#	animation_player.play("Left_wall_slide")


func state_transition_logic():
	if player.is_dead:
		state_machine.transition_to("Die")
	elif player.is_on_floor():
		state_machine.transition_to("Land")
	elif !player.is_on_wall():
		state_machine.transition_to("Air")
	elif Input.is_action_just_pressed("jump") && player.jump_count == 1:
		state_machine.transition_to("Air", {jumped = true})
	
