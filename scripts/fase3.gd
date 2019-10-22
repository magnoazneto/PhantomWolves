extends Node

func _on_FaseComplete_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene("res://scenes/World.tscn")
