extends KinematicBody2D

const FLOOR = Vector2(0, -1)
const WOLF_CLAW_DAMAGE = 20
const GRAVITY = 20

onready var target = null

var SPEED = 300
var motion = Vector2()
var direction = 1 setget set_dir
var react_time = 400
var next_dir = 0
var next_dir_time = 0
var health = 5 setget set_hp, get_hp
var target_safe_distance = 75
var next_jump_time = -1
var next_atack_time = 0
var dead = false
var waiting_dir_change = false
var seeking = false

func _ready():
	$atack.visible = false
	$dying.visible = false

func _physics_process(delta):
	_check_life()
	_check_target_distance()


# Função para fazer o lobo andar de um lado para outro em modo passivo
func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	if is_on_floor() and body.name != "Player" and body.name != "fire_shoot":
		direction = direction * -1


# Função de receber damage
func _on_hitbox_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.name == "fire_shoot":
		damage()


func _check_life():
	motion.y += GRAVITY
	_check_position()
	if get_hp() <= 0:
		wolf_dying()
	else: 
		$wolf.play("walk")

# FUNÇÃO PRA CONFIGURAR DIREÇÃO DO LOBO DE ACORDO COM UM REACT TIME
func set_dir(target_dir): 
	direction = target_dir

func _check_target_distance():
	if target != null and not dead:
		if global_position.distance_to(target.global_position) < 50: 
			# Ataca caso o inimigo esteja em distância < 50
			wolf_atack(direction)
		
		# Script de movimentação - seguindo player
		if (target.position.x < position.x + target_safe_distance) and not waiting_dir_change:
			next_dir = -1
			set_dir(-1)
			waiting_dir_change = true
			$next_dir_timer.start()
		elif target.position.x > position.x + target_safe_distance and not waiting_dir_change:
			next_dir = 1
			set_dir(1)
			waiting_dir_change = true
			$next_dir_timer.start()
		
		motion.x = direction * SPEED
		
		# Verifica necessidade de pulo
		if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
			if target.position.y < position.y - 20:
				motion.y = -400
			next_jump_time = -1
		
		if target.position.y < position.y and next_jump_time == -1:
			next_jump_time = OS.get_ticks_msec() + react_time
		
		$wolf.flip_h = true if direction == 1 else false
		motion = move_and_slide(motion, FLOOR)
	else:
		if not dead:
			motion.x = direction * SPEED
			$wolf.flip_h = true if direction == 1 else false
			motion = move_and_slide(motion, FLOOR)

func _check_position():
	if position.y > 5000 and not dead:
		set_hp(0)


func damage():
	set_hp(get_hp() - 1)
	SPEED += 30


func set_hp(new_hp):
	health = new_hp


func get_hp():
	return health


func wolf_atack(direction):
	$atack.flip_h = true if direction == 1 else false

	if OS.get_ticks_msec() > next_atack_time:
		$atack.frame = 0
		$wolf.visible = false
		$atack.visible = true
		$atack.play("clawAtack")
		next_atack_time = OS.get_ticks_msec() + 800
	
	
func wolf_dying():
	dead = true
	$wolf.visible = false
	$dying.visible = true
	$dying.flip_h = true if direction == 1 else false
	$dying.play("dyingAnim")


func _on_atack_animation_finished():
	$atack.visible = false
	$wolf.visible = true
	target.decrease_life(WOLF_CLAW_DAMAGE)

func _on_dying_animation_finished():
	Network.dead_wolves += 1
	queue_free()


func _on_next_dir_timer_timeout():
	set_dir(next_dir)
	waiting_dir_change = false


func _on_SeekArea_body_entered(body):
	if not seeking and body.is_in_group("players"):
		target = get_parent().get_parent().get_node(body.name)
		seeking = true
		$seek_timer.start()


func _on_seek_timer_timeout():
	seeking = false
