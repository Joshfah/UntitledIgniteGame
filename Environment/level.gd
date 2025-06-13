class_name Level
extends Node2D

@export_range(10.0, 600.0, 0.5) var time_cycle_duration := 180.0
@export_group("Coldness", "coldness")
@export_range(0.01, 5.0, 0.01, "or_greater") var coldness_at_day := 1.5
@export_range(0.01, 5.0, 0.01, "or_greater") var coldness_at_evening := 3.0
@export_range(0.01, 5.0, 0.01, "or_greater") var coldness_at_night := 5.0
@export_group("Time Color Mood", "mood_color")
@export var mood_color_day : Color = Color(0.78, 0.78, 0.78)
@export var mood_color_evening : Color = Color(0.61, 0.404, 0.342)
@export var mood_color_night : Color = Color(0.182, 0.193, 0.23)

@onready var _canvas := $CanvasModulate

func _ready() -> void:
	_time_cycle_setup()

func _process(_delta: float) -> void:
	_canvas.color = TimeCycleAutoload.current_mood_color

func _time_cycle_setup() -> void:
	var cycle := TimeCycleAutoload
	cycle.coldness_at_day = coldness_at_day
	cycle.coldness_at_evening = coldness_at_evening
	cycle.coldness_at_night = coldness_at_night
	cycle.mood_color_day = mood_color_day
	cycle.mood_color_evening = mood_color_evening
	cycle.mood_color_night = mood_color_night
	cycle.time_cycle_duration = time_cycle_duration
