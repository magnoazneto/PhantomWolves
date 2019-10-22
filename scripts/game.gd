extends Node

var total_wolves = 6
var checkpoint_position = Vector2(202, 192)
onready var spawn_text = get_node("HUD/text_back/DialogBox")

func _ready():
	$music_theme.play()

func _on_WorldComplete_body_entered(body):
	var dead_counter = get_node("HUD/wolf_counter/counter").wolf_die
	var max_counter = get_node("HUD/wolf_counter/counter").wolf_max
	if body.name == "Player" and dead_counter >= max_counter:
		get_tree().change_scene("res://scenes/fase2.tscn")
	else:
		$Player/Camera2D/ScreenShake.start(0.2, 40)
		spawn_text.start("There are wolves here...")
		

func _on_magic_boost_body_entered(body):
	if body.name == "Player":
		var noaz = get_node("Player")
		noaz.fire_max = 1.5
		noaz.fire_amount = noaz.fire_max
		get_node("magic_boost").queue_free()
		spawn_text.start("Release your fire, Noaz!")

func _on_music_theme_finished():
	$music_theme.play()

func _on_NotifyArea_body_entered(body):
	if body.name == "Player":
		spawn_text.start("You have to trust yourself now.")

func _on_NotifyArea2_body_entered(body):
	if get_node("Enemys/Enemy3") != null:
		if body.name == "Player": #and get_node("Enemys/Enemy6").health > 0:
			spawn_text.start("You should look to the sky right now...")

func _on_CheckPoint_body_entered(body):
	if body.name == "Player":
		spawn_text.start("Position Saved")
		checkpoint_position = get_node("Player").global_position
		get_node("CheckPoint").queue_free()

func _on_CureFire_body_entered(body):
	if body.name == "Player": get_node("Player").HP = 100
