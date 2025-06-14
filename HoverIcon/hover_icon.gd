## Diese Klasse kann man nutzen, um zb anzuzeigen, welchen Button man gerade drücken kann.
## Nützliche Methoden in dieser Klasse: hide(), show(), animate_failing()
class_name HoverIcon
extends Sprite2D

@export var fail_modulate := Color(0.42, 0.0, 0.0)
@export_range(1.0, 10.0, 0.5) var bounce_height := 4.0
@export_range(0.1, 2.0, 0.1) var animation_speed := 1.0

var _modulate_tween : Tween

func _ready() -> void:
	_set_hover_tween()

## HoverIcon wird kurz rot. Dient dafür, um den Spieler zu zweigen, dass etwas nicht stimmt.
func animate_failing() -> void:
	_reset_tween()
	modulate = fail_modulate
	_modulate_tween.tween_property(self, "modulate", Color(1, 1, 1), 1.0)

func _reset_tween() -> void:
	if not _modulate_tween:
		_modulate_tween = create_tween()
		return
	if _modulate_tween.is_running():
		_modulate_tween.kill()
	_modulate_tween = create_tween()

func _set_hover_tween() -> void:
	var anchor_position := position
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", Vector2(0.0, -bounce_height) + anchor_position, animation_speed / 2.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", anchor_position, animation_speed / 2.0).set_ease(Tween.EASE_IN)
