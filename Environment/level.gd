class_name Level
extends Node2D

@export var amount_wood : int
@export_range(10.0, 600.0, 0.5) var time_cycle_duration := 180.0
@export_group("Coldness", "coldness")
@export_range(0.01, 5.0, 0.01, "or_greater") var coldness_at_day := 1.5
@export_range(0.01, 5.0, 0.01, "or_greater") var coldness_at_evening := 3.0
@export_range(0.01, 5.0, 0.01, "or_greater") var coldness_at_night := 5.0
@export_group("Time Color Mood", "mood_color")
@export var mood_color_day : Color = Color(0.78, 0.78, 0.78)
@export var mood_color_evening : Color = Color(0.61, 0.404, 0.342)
@export var mood_color_night : Color = Color(0.182, 0.193, 0.23)

@onready var _pause_menu := $CanvasLayer/PauseMenu
@onready var _items := $Items
@onready var _snowMap := $NavigationRegion2D/TileMaps/Snow
@onready var _obsaclesMap := $NavigationRegion2D/TileMaps/Obstacles
@onready var _canvas := $CanvasModulate
@onready var _animation_player := $AnimationPlayer
@onready var _trader := $NavigationRegion2D/Trader

var final_day_passed := false

func _ready() -> void:
	PlayerAutoload.player.hurtbox.no_health.connect(_on_player_died)
	TimeCycleAutoload.final_day_passed.connect(_on_final_day_passed)
	TimeCycleAutoload.start()
	_animation_player.play("white")
	_canvas.show()
	spawn_wood()
	_time_cycle_setup()

func _process(_delta: float) -> void:
	_canvas.color = TimeCycleAutoload.current_mood_color

func spawn_wood() -> void:
	
	for i in range(amount_wood):
		var placeTile : Vector2i = Vector2i(randi_range(-66, 67), randi_range(-48, 57)) # musste tilemapgröße manuell eingeben, hat anders nicht funktioniert
		
		while _obsaclesMap.get_cell_tile_data(placeTile) != null or placeTile.x <= 7 && placeTile.x >= 5 && placeTile.y <= 47 && placeTile.y >= 46:
			placeTile = Vector2i(randi_range(-66, -48), randi_range(67, 57))
		
		var global_pos : Vector2 = _snowMap.map_to_local(placeTile)
		
		var wood_scene : PackedScene = load("res://Items/wood_item.tscn")
		var wood_instance : Node2D = wood_scene.instantiate()
		
		wood_instance.duplicate(true)
		
		_items.add_child(wood_instance)
		wood_instance.global_position = global_pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = true
		_pause_menu.show()

func _on_player_died() -> void:
	print("Player died")
	PlayerAutoload.player.set_physics_process(false)
	TimeCycleAutoload.cycle_stopped = true
	if final_day_passed:
		_animation_player.play("win")
	else:
		_animation_player.play("lose")

func _on_final_day_passed() -> void:
	_trader.queue_free()
	#for child in _items.get_children():
		#child.queue_free()
	final_day_passed = true

func _time_cycle_setup() -> void:
	var cycle := TimeCycleAutoload
	cycle.coldness_at_day = coldness_at_day
	cycle.coldness_at_evening = coldness_at_evening
	cycle.coldness_at_night = coldness_at_night
	cycle.mood_color_day = mood_color_day
	cycle.mood_color_evening = mood_color_evening
	cycle.mood_color_night = mood_color_night
	cycle.time_cycle_duration = time_cycle_duration

func _win() -> void:
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
