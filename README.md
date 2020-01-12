# Gameplay

Este projeto consiste em um jogo de plataforma multiplayer, onde o primeiro que finalizar a fase vence. Inicialmente o objetivo é simples: matar os 6 _Phantom Wolves_ que existem espalhados pelo mapa. 

# Funcionamento
Começando pelo próprio Lobby, o jogo coleta o Nickname do usuário e o permite escolher entre a criação de um server ou entrar em um existente na rede como client.
```python
func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	_load_game()

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene("res://scenes/World.tscn")
```

O núcleo do controle de rede está no script "Network.gd", e tanto a função _Create_ como _Join_ acessam funcionalidades desse script. Ele é um _autoload script._

```python
func create_server(player_nickname):
	self_data.name = player_nickname
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
```

E a definição de movimentação dos players está definida no modelo slave-master, e cada player herda do node _KinematicBody2D_:

```python
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
```


