class_name HurtBox
extends Area2D

signal no_health
signal get_hurt

@export_range(0, 20, 1) var max_health := 10

var health : int: set = set_health

func _ready() -> void:
	await get_tree().physics_frame
	set_health(max_health)

func set_health(new_health) -> void:
	health = clamp(new_health, 0, max_health)
	UiAutoload.ui.set_health(health)
	print(health)
	if health == 0:
		no_health.emit()

func get_damage(damage: int) -> void:
	set_health(health - damage)
	get_hurt.emit()
	print("Player's Health: " + str(health))
