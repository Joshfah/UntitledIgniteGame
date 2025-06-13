class_name UI
extends Control

## The intensity of the injury animation. That means the pulse will bounce more intense.
@export_range(0.0, 1.0, 0.01) var injury_intensity := 0.1
@export_range(0.1, 2.0, 0.05) var pulse_speed := 0.5

@onready var hearts : Node2D = $Hearts
@onready var _stamina_bar := $StaminaBar
@onready var _frost_bar := $FrostBar
@onready var _frost_hud := $FrostHUD
@onready var _injury_hud := $InjuryHUD

var player : Player = PlayerAutoload.player

var max_health : int = 6
var health := 6: set = set_health
var current_stamina := 0.0
var max_stamina := 1.0: set = set_max_stamina
var current_frost := 0.0
var max_frost := 1.0: set = set_max_frost
var heartsprites : Array[Node]

var _tween : Tween

func _ready() -> void:
	UiAutoload.ui = self
	_tween = create_tween()
	_reset_tween()
	heartsprites = hearts.get_children()

func _process(_delta: float) -> void:
	_heart_ui_process()
	_stamina_ui_process()
	_frost_ui_process()

func set_health(new_health: int) -> void:
	health = new_health
	_update_injury_animation()

func set_max_stamina(new_max_stamina: float) -> void:
	max_stamina = new_max_stamina
	_stamina_bar.max_value = max_stamina

func set_max_frost(new_max_frost: float) -> void:
	max_frost = new_max_frost
	_frost_bar.max_value = max_frost

func _update_injury_animation() -> void:
	if not is_inside_tree():
		await ready
	_reset_tween()
	var density_progress := 1.0 - float(health) / float(max_health)
	var pulse_time := pulse_speed / density_progress if density_progress > 0.4 else 0.0
	if not pulse_time:
		_tween.kill()
		_injury_hud.set_line_density(density_progress)
		return
	_tween.tween_method(
		_injury_hud.set_line_density, 
		density_progress, 
		density_progress - injury_intensity, 
		pulse_time
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(
		_injury_hud.set_line_density,
		density_progress - injury_intensity,
		density_progress,
		pulse_time
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func _heart_ui_process() -> void:
	var hearts_remainingf : float = float(health) / 2
	hearts_remainingf += 0.5
	
	var hearts_remaining : int = int(hearts_remainingf)
	
	for n in range(heartsprites.size()):
		if n <= hearts_remaining - 1:
			heartsprites[n].texture.set("region", Rect2(0, 0, 32, 32))
		if n > hearts_remaining - 1:
			heartsprites[n].texture.set("region", Rect2(64, 0, 32, 32))
		
	if health % 2 != 0:
		heartsprites[hearts_remaining - 1].texture.set("region", Rect2(32, 0, 32, 32))

func _stamina_ui_process() -> void:
	_stamina_bar.value = current_stamina

func _frost_ui_process() -> void:
	_frost_bar.value = current_frost
	_frost_hud.set_line_density(current_frost / max_frost)

func _reset_tween() -> void:
	if not _tween:
		return
	_tween.kill()
	_tween = create_tween()
	_tween.set_loops()
