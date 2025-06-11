class_name Enemy
extends CharacterBody2D


@onready var _hurt_box := $HurtBox
@onready var _nav_agent := $NavigationAgent2D
@onready var _reachable_area := $ReachableArea

func _ready() -> void:
	_hurt_box.no_health.connect(_die)

func _physics_process(delta: float) -> void:
	pass

func _die() -> void:
	queue_free()
