extends Node2D

@onready var hover_sprite : Sprite2D = $HoverIcon

var player : Player = PlayerAutoload.player

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("INTERACT"):
		queue_free()
		player.has_axe = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		hover_sprite.show()
		
		set_process(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		hover_sprite.hide()
		
		set_process(false)
