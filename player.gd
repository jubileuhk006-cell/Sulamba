extends CharacterBody2D

# Propriedades do personagem
@export var max_health = 100
@export var max_energy = 100
@export var speed = 200
@export var jump_force = -400
@export var gravity = 800

var health = max_health
var energy = max_energy
var is_attacking = false
var is_transformed = false
var combo_counter = 0
var last_attack_time = 0
var combo_reset_time = 0.5

# Velocidade vertical
var velocity_y = 0

func _ready():
	health = max_health
	energy = max_energy

func _physics_process(delta):
	# Movimentação horizontal
	var input_velocity = Input.get_axis("ui_left", "ui_right") * speed
	velocity.x = input_velocity
	
	# Gravidade e pulo
	if not is_on_floor():
		velocity_y += gravity * delta
	else:
		velocity_y = 0
		if Input.is_action_just_pressed("ui_up"):
			velocity_y = jump_force
		
	velocity.y = velocity_y
	move_and_slide()
	
	# Ataques
	if Input.is_action_just_pressed("ui_select"):
		light_attack()
	
	if Input.is_action_just_pressed("ui_accept"):
		heavy_attack()
	
	# Transformação Super Saiyajin
	if Input.is_action_just_pressed("ui_focus_next"):
		if energy >= 30:
			toggle_transformation()
	
	# Regeneração de energia lenta
	if energy < max_energy:
		energy += 20 * delta
		energy = min(energy, max_energy)
	
	# Reset de combo
	if Time.get_ticks_msec() - last_attack_time > combo_reset_time * 1000:
		combo_counter = 0

func light_attack():
	if energy >= 10:
		is_attacking = true
		energy -= 10
		combo_counter += 1
		last_attack_time = Time.get_ticks_msec()
		
		# Criar hitbox temporária
		var damage = 10 + (5 * combo_counter)
		if is_transformed:
			damage *= 1.5
		
		print("Ataque Leve! Dano: ", damage, " Combo: ", combo_counter)
		await get_tree().create_timer(0.3).timeout
		is_attacking = false

func heavy_attack():
	if energy >= 25:
		is_attacking = true
		energy -= 25
		combo_counter = 0
		last_attack_time = Time.get_ticks_msec()
		
		var damage = 30
		if is_transformed:
			damage *= 2
		
		print("Ataque Pesado! Dano: ", damage)
		await get_tree().create_timer(0.5).timeout
		is_attacking = false

func toggle_transformation():
	is_transformed = !is_transformed
	energy -= 30
	
	if is_transformed:
		print("SUPER SAIYAJIN!")
		modulate = Color.YELLOW
		speed *= 1.3
	else:
		print("Transformação desativada")
		modulate = Color.WHITE
		speed /= 1.3

func take_damage(damage: int):
	health -= damage
	print("Tomou ", damage, " de dano! Saúde: ", health)
	
	if health <= 0:
		die()

func die():
	print("Você foi derrotado!")
	queue_free()

func get_health_percent():
	return float(health) / float(max_health)

func get_energy_percent():
	return float(energy) / float(max_energy)