extends Control

@onready var _music_slider := $VBoxContainer/MusicSlider
@onready var _soundeffects_slider := $VBoxContainer/SoundeffectsSlider


func _ready() -> void:
	_music_slider.value = AudioServer.get_bus_volume_linear(0)


func _on_music_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)


func _on_soundeffects_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
