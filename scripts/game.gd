extends Node

onready var spawn_text = get_node("HUD/text_back/DialogBox")

func _ready():
	$music_theme.play()
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://scenes/player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)


func _on_player_disconnected(id):
	get_node(str(id)).queue_free()
	if Network.has_winner:
		get_tree().change_scene('res://scenes/Lobby.tscn')

func _on_server_disconnected():
	get_tree().change_scene('res://scenes/Lobby.tscn')

func _on_WorldComplete_body_entered(body):
	var dead_counter = Network.dead_wolves
	var max_counter = Network.total_wolves
	var this_player = get_node(body.name)
	if body.is_in_group("players") and dead_counter >= max_counter:
		if not Network.has_winner:
			Network.winner_name = this_player.get_node("HealthBar/Nickname").text
			Network.has_winner = true
			spawn_text.start(this_player.get_node("HealthBar/Nickname").text + " has won the game!")
			var peer = NetworkedMultiplayerENet.new()
			if is_network_master():
				peer.close_connection()
			else:
				peer.disconnect_peer(get_tree().get_network_unique_id())
		get_tree().change_scene("res://scenes/Lobby.tscn")
	else:
		this_player.get_node("Camera2D/ScreenShake").start(0.2, 40)
		spawn_text.start("There are wolves here...")
		

func _on_magic_boost_body_entered(body):
	if body.is_in_group("players"):
		var this_player = get_node(body.name)
		this_player.fire_max = 1.5
		this_player.fire_amount = this_player.fire_max
		get_node("magic_boost").queue_free()
		spawn_text.start("Release your fire, " + this_player.get_node("HealthBar/Nickname").text + "!")

func _on_music_theme_finished():
	$music_theme.play()

func _on_NotifyArea_body_entered(body):
	if body.is_in_group("players"):
		spawn_text.start("You have to trust yourself now.")

func _on_NotifyArea2_body_entered(body):
	if get_node("Enemys/Enemy3") != null:
		if body.is_in_group("players"): #and get_node("Enemys/Enemy6").health > 0:
			spawn_text.start("You should look to the sky right now...")

func _on_CheckPoint_body_entered(body):
	if body.is_in_group("players"):
		var current_player = get_node(body.name)
		current_player.checkpoint_position = current_player.global_position
		spawn_text.start("Position of " + current_player.get_node("HealthBar/Nickname").text + " saved")

func _on_CureFire_body_entered(body):
	if body.is_in_group("players"): get_node(body.name).set_hp(100)
