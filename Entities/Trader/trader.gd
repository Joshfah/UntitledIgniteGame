class_name Trader
extends StaticBody2D

@export var axe_pickup_scene : PackedScene
@export_range(0, 10, 1) var axe_cost := 5
@export_range(0, 10, 1) var heal_cost := 2

@onready var _area := $Area2D
@onready var _drop_path := $DropPath

var axe_sold := false
var is_player_nearby := false

func _ready() -> void:
	_area.body_entered.connect(_on_area_body_entered)
	_area.body_exited.connect(_on_area_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("INTERACT") and is_player_nearby:
		if not axe_sold:
			_sell_axe()
		else:
			_sell_heal()

func _sell_axe() -> void:
	var player := PlayerAutoload.player
	if player.wood < axe_cost or not axe_pickup_scene:
		return
	# Initialisierung
	var axe_pickup := axe_pickup_scene.instantiate()
	var path_follow := PathFollow2D.new()
	path_follow.rotates = false
	path_follow.loop = false
	_drop_path.add_child(path_follow)
	path_follow.add_child(axe_pickup)
	# Animation
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(path_follow, "progress_ratio", 1.0, 2.0)
	
	axe_sold = true

func _sell_heal() -> void:
	var player := PlayerAutoload.player
	if player.wood < heal_cost:
		return
	player.wood -= heal_cost
	player.heal(2)

func _on_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_nearby = true

func _on_area_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_nearby = false
