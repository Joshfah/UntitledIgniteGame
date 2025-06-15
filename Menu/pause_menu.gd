extends Control

@onready var _option_menu := $OptionMenu
@onready var _pause_page := $PausePage
@onready var _help_page := $HelpPage


func _ready() -> void:
	_option_menu.closed.connect(_pause_page.show)


func _on_play_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_option_button_pressed() -> void:
	_pause_page.hide()
	_option_menu.show()


func _on_cancel_button_pressed() -> void:
	_help_page.hide()
	_pause_page.show()


func _on_help_button_pressed() -> void:
	_help_page.show()
	_pause_page.hide()
