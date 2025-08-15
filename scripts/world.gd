extends Node2D

const player_scene = preload("res://scenes/player.tscn")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Spawn local player for everyone
	rpc("_spawn_player", multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func _spawn_player(peer_id: int):
	if player_scene == null:
		push_error("Player scene not set!")
		return

	# Avoid spawning same player twice
	if has_node(str(peer_id)):
		return

	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	add_child(player)

func _on_peer_connected(id):
	# Host tells the new peer to spawn all existing players
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			rpc_id(id, "_spawn_player", peer)
		rpc_id(id, "_spawn_player", multiplayer.get_unique_id())

func _on_peer_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()
