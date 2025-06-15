extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_play_button_pressed()


func _on_play_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_option_button_pressed() -> void:
	pass # Replace with function body.
