extends Control

@onready var _animation_player := $AnimationPlayer
@onready var _color_rect := $ColorRect
@onready var _start_page := $StartPage
@onready var _option_menu := $OptionMenu

func _ready() -> void:
	_animation_player.play("white")
	_option_menu.closed.connect(_start_page.show)


func _on_play_button_pressed() -> void:
	_animation_player.play("black")
	_color_rect.mouse_filter = 0


func _on_option_button_pressed() -> void:
	_start_page.hide()
	_option_menu.show()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "black":
		get_tree().change_scene_to_file("res://Environment/level.tscn")
