extends Node2D

@onready var level := $".."
@onready var intro := $Intro
@onready var background := $BackgroundLoop

func _ready() -> void:
	level.ready.connect(_play_intro)

func _play_intro() -> void:
	print("Intro")
	intro.play()

func _on_intro_finished() -> void:
	print("looping")
	background.play()
