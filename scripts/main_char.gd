extends KinematicBody2D

onready var MAX_SPEED = 500
onready var ACCELERATION = 10
onready var sliding = 0.1
onready var hp_bar = $Camera2D/HUD/HealthBar/HealthBar

const UP = Vector2(0, -1)
const GRAVITY = 20
const JUMP_HEIGHT = -500
const FIREBALL = preload("res://scenes/Fireball.tscn")
const SCREEN_SHAKE = preload("res://scenes/ScreenShake.tscn")

var bala_na_agulha = false
var fire_shoot = null
var fire_amount = 1
var fire_max = 1
var HP = 100
var previous_HP = 100
var direction = 0
var motion = Vector2()
var db_jump = false

func _physics_process(delta):
	check_life()
	if Input.is_action_just_pressed("ui_reset"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
		direction = 1
		$Sprite.play("Run")
		motion.x = MAX_SPEED
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		direction = -1
		$Sprite.play("Run")
		motion.x = -MAX_SPEED
	else:
		$Sprite.play("Idle")
		motion.x = lerp(motion.x, 0, sliding)
		if HP < 100:
			HP += 0.01
		
	if is_on_floor():
		db_jump = true
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
		elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
			# CHARGING CODE
			set_fire(true, Vector2(0, -50), 0, false, false, "fireCharge")
			if fire_amount < fire_max:
				$Sprite.play("Charge")
				fire_amount += 0.02
				$Camera2D/ScreenShake.start()
				
			else:
				$Sprite.play("Idle")
				$fire_charge_sound.play()

	else:
		if motion.y < 0:
			$Sprite.play("Jump")
		else:
			$Sprite.play("Fall")
		if Input.is_action_pressed("ui_down"):
			$Sprite.play("Drop")
			set_fire(true, Vector2(0, -100), 0, false, false)
			motion.y += 20
		
		# FLY
		elif Input.is_action_pressed("ui_up") and fire_amount > 0.1:
			$Sprite.play("DoubleJump")
			motion.y = JUMP_HEIGHT
			set_fire(true, Vector2(0, 90), 0, true, false)
			fire_amount -= 0.004
		
		# DOUBLE JUMP
		elif Input.is_action_just_pressed("ui_up") and db_jump:
				motion.y = JUMP_HEIGHT
				set_fire(true, Vector2(0, 90), 0, true, false)
				db_jump = false
	
	if not bala_na_agulha:
		fire_shoot = FIREBALL.instance()
		bala_na_agulha = true
		
		# DISPARO DA FIREBALL
	if Input.is_action_just_pressed("ui_accept") and fire_amount > 0:
		if $Sprite.flip_h:
			fire_shoot.direction = -1
			$Hand.position.x = -40
			fire_shoot.speed -= motion.x
		else:
			fire_shoot.direction = 1
			$Hand.position.x = 40
			fire_shoot.speed += motion.x
		fire_shoot.scale = Vector2(max(0.08, fire_amount/4), max(0.08, fire_amount/4))
		fire_shoot.atirar = true
		fire_amount -= 0.1
		get_parent().add_child(fire_shoot)
		bala_na_agulha =  false
		fire_shoot.position = $Hand.global_position
		$fireball_sound.play()

	motion = move_and_slide(motion, UP)


func check_life():
	motion.y += GRAVITY
	$Sprite/fire.visible = false
	if HP != previous_HP:
		$Tween.interpolate_property(hp_bar, "value", previous_HP, HP, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.start()
	previous_HP = HP
	if HP <= 0:
		global_position = get_parent().checkpoint_position
		HP = 30
	if global_position.y >= 5000 or global_position.y <= -1000 or global_position.x >= 9500 or global_position.x <= -1000:
		global_position = get_parent().checkpoint_position


func set_fire_color(red, green, blue):
	$Sprite/fire/central_light.color.r = red
	$Sprite/fire/central_light.color.g = green
	$Sprite/fire/central_light.color.b = blue


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
