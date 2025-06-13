class_name UI
extends Control

@onready var hearts : Node2D = $Hearts
@onready var _stamina_bar := $StaminaBar
@onready var _frost_bar := $FrostBar
@onready var _frost_hud := $FrostHUD

var player : Player = PlayerAutoload.player

#var max_health : int = 6
var health : int
var current_stamina := 0.0
var max_stamina := 1.0: set = set_max_stamina
var current_frost := 0.0
var max_frost := 1.0: set = set_max_frost
var heartsprites : Array[Node]

func _ready() -> void:
	UiAutoload.ui = self
	
	heartsprites = hearts.get_children()

func _process(_delta: float) -> void:
	_heart_ui_process()
	_stamina_ui_process()
	_frost_ui_process()

func set_max_stamina(new_max_stamina: float) -> void:
	max_stamina = new_max_stamina
	_stamina_bar.max_value = max_stamina

func set_max_frost(new_max_frost: float) -> void:
	max_frost = new_max_frost
	_frost_bar.max_value = max_frost

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
