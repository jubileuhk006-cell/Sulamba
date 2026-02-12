extends KinematicBody2D

export var speed = 200
export var jump_force = -400
export var gravity = 800

var velocity = Vector2.ZERO
var is_jumping = false

func _physics_process(delta):
	# Movimento horizontal
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	
	velocity.x = input_vector.x * speed
	
	# Gravidade e pulo
	velocity.y += gravity * delta
	
	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jump_force
			is_jumping = true
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Animação
	if input_vector.x != 0:
		$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = input_vector.x < 0
	else:
		$AnimatedSprite.play("idle")
	
	# Morrer se cair muito
	if position.y > 1000:
		get_tree().reload_current_scene()