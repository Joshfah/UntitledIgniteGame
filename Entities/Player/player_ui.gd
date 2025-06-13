class_name UI
extends Control

@onready var hearts : Node = $Hearts

var player : Player = PlayerAutoload.player

var max_health : int = 6
var health : int

var heartsprites : Array[Node]

func _ready() -> void:
	UiAutoload.ui = self
	
	heartsprites = hearts.get_children()

func _process(_delta: float) -> void:
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
