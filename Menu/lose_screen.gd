extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Environment/level.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
