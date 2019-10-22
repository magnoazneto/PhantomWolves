extends KinematicBody2D

onready var target = get_parent()

var GRAVITY = 20
var SPEED = 400
const FLOOR = Vector2(0, -1)

var motion = Vector2()
var direction = 1
var direction_y = 1
var react_time = 400
var next_dir = 0
var next_dir_y = 0
var next_dir_time = 0
var next_dir_y_time = 0
var next_jump_time = -1

var target_distance = 30

func _ready():
	set_process(true)

# FUNÇÃO PRA CONFIGURAR DIREÇÃO DA LISS DE ACORDO COM UM REACT TIME
func set_dir(target_dir): 
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time
		

func set_dir_y(target_dir_y): 
	if next_dir_y != target_dir_y:
		next_dir_y = target_dir_y
		next_dir_y_time = OS.get_ticks_msec() + react_time

func _physics_process(delta):
	motion.y += GRAVITY
	# Script de movimentação - seguindo player
	if global_position.distance_to(target.global_position) > 150:
		#get_node("CollisionShape2D").disabled = false
		if target.position.x < position.x + target_distance:
			set_dir(-1)
		elif target.position.x > position.x + target_distance:
			set_dir(1)
		else:
			set_dir(0)
			
		if OS.get_ticks_msec() > next_dir_time:
			direction = next_dir
		
		if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1:
				if target.position.y < position.y - 20:
					motion.y = -400
				next_jump_time = -1
			
		if target.position.y < position.y and next_jump_time == -1:
			next_jump_time = OS.get_ticks_msec() + react_time
			
		
	
	
	motion.x = direction * SPEED
	#if OS.get_ticks_msec() > next_dir_y_time:
	#	direction_y = next_dir_y	
	motion = move_and_slide(motion, FLOOR)

