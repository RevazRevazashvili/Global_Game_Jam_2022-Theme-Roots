extends PlayerState


export (NodePath) var _animation_player
onready var animation_player:AnimatedSprite = get_node(_animation_player)

func enter(_msg := {}):
	player.stop_particle_emission()
	
	if(player.is_facing_right):
		animation_player.play("Idle_right")
	else :
		animation_player.play("Idle_left")

func handle_input(_event: InputEvent) -> void:
	player._handle_hook_input(_event)

func physics_update(delta: float):
	if !player.is_on_floor():
		state_machine.transition_to("Air")
	
	player.velocity.x = 0
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	player.manage_hook_physics(delta)
	
	state_transition_logic()

func state_transition_logic():
	if player.is_dead:
		state_machine.transition_to("Die")
	
	if !player.is_on_floor():
		state_machine.transition_to("Air")
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jumped = true})
	elif Input.is_action_just_pressed("hide"):
		if(!player.chain.hooked):
			state_machine.transition_to("Hide")
	elif !is_zero_approx(player._get_input_direction()):
		state_machine.transition_to("Run")
	
	#do we need hooked condition?? nah


