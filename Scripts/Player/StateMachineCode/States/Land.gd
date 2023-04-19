extends PlayerState


export (NodePath) var _animation_player
onready var animation_player:AnimatedSprite = get_node(_animation_player)

var landing_camera_shake_intensity = 5.0
var landing_camera_shake_duration = 0.01

func enter(_msg := {}):
	player.jump_count = player.AIR_JUMP_AMOUNT
	
	if(player.is_facing_right):
		animation_player.play("Land_right")
	else :
		animation_player.play("Land_left")
	player.timer.start(0.2)
	Shake.shake(landing_camera_shake_intensity, landing_camera_shake_duration)

func handle_input(_event: InputEvent) -> void:
	player._handle_hook_input(_event)

func physics_update(delta: float):
	if !player.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	player.velocity.x = 0
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	state_transition_logic()

func state_transition_logic():
	if player.is_dead:
		state_machine.transition_to("Die")
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jumped = true})
	elif Input.is_action_just_pressed("hide"):
		if(!player.chain.hooked):
			state_machine.transition_to("Hide")
	elif !is_zero_approx(player._get_input_direction()):
		state_machine.transition_to("Run")

func _on_Timer_timeout():
	if(get_parent().state == self):
		state_machine.transition_to("Idle")
