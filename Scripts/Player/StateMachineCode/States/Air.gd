extends PlayerState


export (NodePath) var _animation_player
onready var animation_player:AnimatedSprite = get_node(_animation_player)

const JUMP_ANIMATION_TIME = 0.4
const DOUBLE_JUMP_ANIMATION_TIME = 0.5

var in_jump

func enter(_msg := {}):
	if(!_msg.has("jumped")):
		change_direction_of_in_air_animation()
		in_jump = false
	elif(player.jump_count == 1):
		handle_double_jump()
		in_jump = true
	elif(player.jump_count == 2):
		handle_jump()
		in_jump = true

func handle_input(_event: InputEvent) -> void:
	player._handle_hook_input(_event)


func update(delta: float):
	if(!in_jump):
		change_direction_of_in_air_animation()


func physics_update(delta: float):
	player.velocity.y += player.GRAVITY

	var fly = player._get_input_direction()*player.MOVE_SPEED
	
	var x = player.velocity.x
	
	#print("(" + str(player.velocity.x) + ":" + str(x) + ")")
	
	
	player.manage_hook_physics(delta)
	
	player.velocity.x += fly
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)	# Actually apply all the forces
	player.velocity.x -= fly
	
	clamp_velocity_and_apply_friction()
	
	state_transition_logic()


func state_transition_logic():
	if player.is_dead:
		state_machine.transition_to("Die")
		return
	
	if !player.chain.hooked:
		if player.is_on_floor():
			state_machine.transition_to("Land")
			return
		elif player.is_on_wall() && (Input.is_action_pressed("left") || Input.is_action_pressed("right")) && !in_jump:
			state_machine.transition_to("Wall_Slide")
			return

	if Input.is_action_just_pressed("jump") && player.jump_count != 0:
		state_machine.transition_to("Air", {jumped = true})
		return
	


func change_direction_of_in_air_animation():
	if(player.is_facing_right):
		animation_player.play("In_air_right")
	else:
		animation_player.play("In_air_left")

func handle_double_jump():
	if(player.is_facing_right):
		animation_player.play("DoubleJump_right")
	else :
		animation_player.play("DoubleJump_left")
			
	player.velocity.y = -player.JUMP_FORCE
	player.jump_count -= 1
	player.timer.start(DOUBLE_JUMP_ANIMATION_TIME)

func handle_jump():
	if(player.is_facing_right):
		animation_player.play("Jump_up_right")
	else:
		animation_player.play("Jump_up_left")
	
	player.velocity.y = -player.JUMP_FORCE
	player.jump_count -= 1
	player.timer.start(JUMP_ANIMATION_TIME)

func clamp_velocity_and_apply_friction():
	# clamp max velocity
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	

	player.velocity.x *= player.FRICTION_AIR
	if player.velocity.y > 0:
		player.velocity.y *= player.FRICTION_AIR

func _on_Timer_timeout():
	if(get_parent().state == self):
		in_jump = false
