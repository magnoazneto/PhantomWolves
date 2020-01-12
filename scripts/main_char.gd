extends KinematicBody2D

onready var SPEED = 500
onready var sliding = 0.1
onready var hp_bar = $HealthBar/HealthBar

const FLOOR = Vector2(0, -1)
const GRAVITY = 20
const JUMP_HEIGHT = -500
const FIREBALL = preload("res://scenes/Fireball.tscn")
const SCREEN_SHAKE = preload("res://scenes/ScreenShake.tscn")

var ready_fireball = false
var fire_shoot = null
var fire_amount = 1
var fire_max = 1
var HP = 100 setget set_hp, get_hp
var previous_HP = 100
var direction = 0
var motion = Vector2()
var db_jump = false
var moving = false
var checkpoint_position = Vector2()

slave var slave_position = Vector2()
slave var slave_up = false
slave var slave_down = false
slave var slave_left = false
slave var slave_right = false
slave var slave_throw_fire = false


func init(nickname, start_position, is_slave):
	$HealthBar/Nickname.text = nickname
	global_position = start_position
	checkpoint_position = start_position
	if is_slave:
		$Camera2D.current = false
		set_fire_color(0, 1, 0)
		$HealthBar/HealthBar.visible = false


func _physics_process(delta):
	_check_life()
	_controls_loop()
	motion = move_and_slide(motion, FLOOR)

	if get_tree().is_network_server():
		Network.update_position(int(name), position)


func _controls_loop():
	#if Input.is_action_just_pressed("ui_reset"): get_tree().reload_current_scene()
	if is_network_master():
		var UP = Input.is_action_pressed("ui_move_up")
		var LEFT = Input.is_action_pressed("ui_move_left")
		var RIGHT = Input.is_action_pressed("ui_move_right")
		var DOWN = Input.is_action_pressed("ui_move_down")
		var THROW_FIREBALL = Input.is_action_just_pressed("ui_accept")
		_movement_loop(UP, DOWN, LEFT, RIGHT)
		_fly_control(UP, DOWN)
		_shoot_control(THROW_FIREBALL)
		rset('slave_up', UP)
		rset('slave_down', DOWN)
		rset('slave_left', LEFT)
		rset('slave_right', RIGHT)
		rset('slave_throw_fire', THROW_FIREBALL)
		rset('slave_position', position)
	
	else:
		_movement_loop(slave_up, slave_down, slave_left, slave_right)
		_fly_control(slave_up, slave_down)
		_shoot_control(slave_throw_fire)
		position = slave_position


func _movement_loop(UP, DOWN, LEFT, RIGHT):
	direction = -int(LEFT) + int(RIGHT)
	moving = true if direction != 0 else false
	
	if moving:
		$Sprite.play("Run")
		motion.x = SPEED * direction
		$Sprite.flip_h = true if direction < 0 else false
	
	else:
		$Sprite.play("Idle")
		motion.x = lerp(motion.x, 0, sliding)
		if HP < 100: HP += 0.01
		if DOWN and is_on_floor():
			_charge()


func _fly_control(UP, DOWN):
	motion.y += GRAVITY
	
	if is_on_floor():
		db_jump = true
		if UP: motion.y = JUMP_HEIGHT

	else:
		var animation_name = "Jump" if motion.y <0 else "Fall"
		$Sprite.play(animation_name)
		
		if DOWN:
			$Sprite.play("Drop")
			set_fire(true, Vector2(0, -100), 0, false, false)
			motion.y += 20
		
		# FLY
		elif UP and fire_amount > 0.1:
			$Sprite.play("DoubleJump")
			motion.y = JUMP_HEIGHT
			set_fire(true, Vector2(0, 90), 0, true, false)
			fire_amount -= 0.004
		
		# DOUBLE JUMP
		elif Input.is_action_just_pressed("ui_move_up") and db_jump:
			motion.y = JUMP_HEIGHT
			set_fire(true, Vector2(0, 90), 0, true, false)
			db_jump = false


func _charge():
	set_fire(true, Vector2(0, -50), 0, false, false, "fireCharge")
	if fire_amount < fire_max:
		$Sprite.play("Charge")
		fire_amount += 0.02
		$Camera2D/ScreenShake.start(0.2, 40)
		
	else:
		$Sprite.play("Idle")
		$fire_charge_sound.play()


func _shoot_control(THROW_FIREBALL):
	if not ready_fireball:
		fire_shoot = FIREBALL.instance()
		ready_fireball = true
		
		# DISPARO DA FIREBALL
	if THROW_FIREBALL and fire_amount > 0:
		if $Sprite.flip_h:
			fire_shoot.set_direction(-1)
			$Hand.position.x = -65
		else:
			fire_shoot.set_direction(1)
			$Hand.position.x = 55
			
		fire_shoot.scale = Vector2(max(0.08, fire_amount/4), max(0.08, fire_amount/4))
		if not is_network_master(): fire_shoot.set_fire_color(0, 1, 0)
		fire_shoot.set_shoot(true)
		fire_amount -= 0.1
		get_parent().add_child(fire_shoot)
		ready_fireball =  false
		fire_shoot.position = $Hand.global_position
		$fireball_sound.play()


func _check_life():
	$Sprite/fire.visible = false
	if HP != previous_HP:
		$Tween.interpolate_property(hp_bar, "value", previous_HP, HP, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.start()
	previous_HP = HP
	if HP <= 0:
		global_position = checkpoint_position
		HP = 30
	if global_position.y >= 5000 or global_position.y <= -1000 or global_position.x >= 9500 or global_position.x <= -1000:
		global_position = checkpoint_position
	
	if Network.has_winner:
		get_tree().change_scene("res://scenes/Lobby.tscn")


func set_hp(value: int):
	HP = value

func get_hp():
	return HP

func decrease_life(value: int):
	set_hp(get_hp() - value)


func set_fire_color(red, green, blue):
	$Sprite/fire/central_light.color.r = red
	$Sprite/fire/central_light.color.g = green
	$Sprite/fire/central_light.color.b = blue
	$Sprite/fire/light_around.color.r = red
	$Sprite/fire/light_around.color.g = green
	$Sprite/fire/light_around.color.b = blue


func set_fire(mode, positions, rotation, v_flip, h_flip, anim = "fireAnim"):
	$Sprite/fire.play(anim)
	$Sprite/fire.visible = mode
	$Sprite/fire.position = positions
	$Sprite/fire.rotation_degrees = rotation
	$Sprite/fire.flip_v = v_flip
	$Sprite/fire.flip_h = h_flip
	if anim == "fireAnim":
		$Sprite/fire.scale = Vector2(fire_amount, fire_amount)
		$fire_fly_sound.play()
	elif anim == "fireCharge":
		$Sprite/fire.scale = Vector2(fire_amount/2, fire_amount/2)
