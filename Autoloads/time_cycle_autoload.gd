extends Node

const DAY_PART := 2.0 / 5.0
const EVENING_PART := 1.0 / 5.0
const NIGHT_PART := 1.0 / 5.0

var coldness_at_day := 1.5
var coldness_at_evening := 3.0
var coldness_at_night := 5.0
var mood_color_day : Color = Color(0.78, 0.78, 0.78)
var mood_color_evening : Color = Color(0.61, 0.404, 0.342)
var mood_color_night : Color = Color(0.182, 0.193, 0.23)

## zieht den fuel von Bonfire pro sekunde ab
var current_coldness := 2.0
var current_mood_color := Color(255)
var time_cycle_duration := 300.0

func _ready() -> void:
	await get_tree().process_frame
	var day_duration := time_cycle_duration * DAY_PART
	var evening_duration := time_cycle_duration * EVENING_PART
	var night_duration := time_cycle_duration * NIGHT_PART
	var tween := create_tween().set_trans(Tween.TRANS_QUART).set_loops(3)
	
	current_coldness = coldness_at_night
	current_mood_color = mood_color_night
	# Night --> Evening
	tween.tween_property(self, "current_mood_color", mood_color_evening, night_duration).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "current_coldness", coldness_at_evening, night_duration).set_ease(Tween.EASE_IN)
	# Evening --> Day
	tween.tween_property(self, "current_mood_color", mood_color_day, evening_duration).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "current_coldness", coldness_at_day, evening_duration).set_ease(Tween.EASE_OUT)
	# Day --> Evening
	tween.tween_property(self, "current_mood_color", mood_color_evening, day_duration).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "current_coldness", coldness_at_evening, day_duration).set_ease(Tween.EASE_IN)
	# Evening --> Night
	tween.tween_property(self, "current_mood_color", mood_color_night, evening_duration).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "current_coldness", coldness_at_night, evening_duration).set_ease(Tween.EASE_OUT)
