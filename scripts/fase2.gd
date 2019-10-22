extends Node

var total_wolves = 3

func _ready():
	$music_theme.play()

func _on_fase2complete_body_entered(body):
	var dead_counter = get_node("HUD/wolf_counter/counter").wolf_die
	var max_counter = get_node("HUD/wolf_counter/counter").wolf_max
	if body.name == "Player" and dead_counter >= max_counter:
		get_tree().change_scene("res://scenes/World.tscn")
	else:
		get_node("HUD/text_back/DialogBox").start("You must to kill all the wolves.")


func _on_magic_boost_body_entered(body):
	if body.name == "Player":
		var noaz = get_node("Player")
		noaz.fire_shoot.scale = Vector2(1.2,1.2)
		noaz.fire_max = 1.5
		noaz.fire_amount = noaz.fire_max
		get_node("magic_boost").queue_free()
		get_node("HUD/text_back/DialogBox").start("Explode, Noaz! Show me your fire!")


func _on_AudioStreamPlayer_finished():
	$music_theme.play()
