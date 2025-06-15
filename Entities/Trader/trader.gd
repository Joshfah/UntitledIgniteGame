class_name Trader
extends StaticBody2D

@export var axe_pickup_scene : PackedScene
@export_range(0, 10, 1) var axe_cost := 5
@export_range(0, 10, 1) var heal_cost := 2
@export_group("Product Icon", "icon")
@export var icon_axe : AtlasTexture
@export var icon_heart : AtlasTexture

@onready var _area := $Area2D
@onready var _drop_path := $DropPath
@onready var _hover_value := $HoverValue
@onready var _product_icon := $ProductIcon

var axe_sold := false
var is_player_nearby := false

func _ready() -> void:
	_hover_value.hide()
	_product_icon.hide()
	_hover_value.set_value(axe_cost)
	_product_icon.texture = icon_axe
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
		_hover_value.animate_failing()
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
	player.wood -= axe_cost
	axe_sold = true
	_hover_value.set_value(heal_cost)
	_product_icon.texture = icon_heart
	_product_icon.scale = Vector2(0.5, 0.5)

func _sell_heal() -> void:
	var player := PlayerAutoload.player
	if player.wood < heal_cost:
		_hover_value.animate_failing()
		return
	player.wood -= heal_cost
	player.heal(2)

func _on_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_nearby = true
	_hover_value.show()
	_product_icon.show()

func _on_area_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_nearby = false
	_hover_value.hide()
	_product_icon.hide()
