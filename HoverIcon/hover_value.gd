class_name HoverValue
extends HoverIcon

@export var value := 0: set = set_value
@export var label_offset := Vector2(8.0, -8.0)

@onready var _label := $Label

func _ready() -> void:
	_set_hover_tween()
	_label.position = label_offset

func set_value(new_value: int) -> void:
	value = new_value
	if value == 0:
		_label.text = ""
		return
	if not _label:
		await ready
	_label.text = str(value)
