extends PlayerState


export (NodePath) var _animation_player
onready var animation_player:AnimatedSprite = get_node(_animation_player)

func enter(_msg := {}):
	player.stop_particle_emission()
	player.jump_count = player.AIR_JUMP_AMOUNT;
	
	if(player.is_facing_right):
		animation_player.play("Death_right")
	else :
		animation_player.play("Death_left")

func handle_input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("restart")):
		player._reset()
		state_machine.transition_to("Idle")
