extends Node2D

var player : Player = PlayerAutoload.player

func _ready() -> void:
	PlayerAutoload.player.remove_wood.connect(_on_remove_wood)

func _on_remove_wood(instance_index : int):
	remove_child(get_child(instance_index))
