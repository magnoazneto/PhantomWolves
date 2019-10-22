extends KinematicBody2D

onready var target = get_parent().get_parent().get_node("Player")

var GRAVITY = 20
var SPEED = 300
const FLOOR = Vector2(0, -1)

var motion = Vector2()
var direction = 1
var react_time = 400
var next_dir = 0
var next_dir_time = 0
var health = 5
var target_distance = 50
var next_jump_time = -1
var next_atack_time = 0
var dead = false

func _ready():
	set_process(true)
	$atack.visible = false

# FUNÇÃO PRA CONFIGURAR DIREÇÃO DO LOBO DE ACORDO COM UM REACT TIME
func set_dir(target_dir): 
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time

func _physics_process(delta):
	if position.y > 5000 and not dead:
		wolf_dying()
		dead = true
	motion.y += GRAVITY
	if health > 0: 
		$wolf.play("walk")
		$wolf.flip_h = true
		$dying.visible = false
	elif not dead:
		$wolf.visible = false
		$wolf.stop()
		wolf_dying()
		dead = true
	
	# Verifica se o inimigo está em distância < 200
	if global_position.distance_to(target.global_position) < 300:
		if global_position.distance_to(target.global_position) < 50 and health > 0:
			# Ataca caso o inimigo esteja em distância < 50
			wolf_atack(direction)
		
		# Script de movimentação - seguindo player
		if target.position.x < position.x + target_distance:
			set_dir(-1)
		elif target.position.x > position.x + target_distance:
			set_dir(1)
		else:
			set_dir(0)
			
		if OS.get_ticks_msec() > next_dir_time:
			direction = next_dir
		
		# Verifica necessidade de pulo
		if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
			if target.position.y < position.y - 20:
				motion.y = -400
			next_jump_time = -1
		
		if target.position.y < position.y and next_jump_time == -1:
			next_jump_time = OS.get_ticks_msec() + react_time
	
	# criação do movimento e set de sprite
	motion.x = direction * SPEED
	if direction == 1:
		$wolf.flip_h = true
	else:
		$wolf.flip_h = false
	motion = move_and_slide(motion, FLOOR)

# Função para fazer o lobo andar de um lado para outro em modo passivo
func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	if is_on_floor() and body.name != "Player" and body.name != "fire_shoot":
		direction = direction * -1


# Função de damage
func _on_hitbox_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == "fire_shoot":
		health -= 1
		SPEED += 30


func wolf_atack(direction):
	if direction == 1:
		$atack.flip_h = true
	else:
		$wolf.flip_h = false
	if OS.get_ticks_msec() > next_atack_time:
		$atack.frame = 0
		$wolf.visible = false
		$atack.visible = true
		$atack.play("clawAtack")
		next_atack_time = OS.get_ticks_msec() + 800
	
	
func wolf_dying():
	$dying.visible = true
	if health > 0:
		if direction == 1:
			$dying.flip_h = false
		else:
			$dying.flip_h = true
	$dying.play("dyingAnim")
	SPEED = 0
	GRAVITY = 1000
	get_parent().get_parent().get_node("HUD/wolf_counter/counter").refresh()

func _on_atack_animation_finished():
	$atack.visible = false
	$wolf.visible = true
	target.HP -= 20

func _on_dying_animation_finished():
	queue_free()
