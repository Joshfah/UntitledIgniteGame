extends Node2D

@onready var wood_sprite : Sprite2D = $Sprite2D 
@onready var hover_sprite : Sprite2D = $HoverIcon

var player : Player = PlayerAutoload.player
var wood_textures : Array[Texture2D] = [preload("res://assets/wood1.png"), preload("res://assets/wood2.png"), preload("res://assets/wood3.png"), preload("res://assets/wood4.png")]

func _ready() -> void:
	set_process(false)
	wood_sprite.texture = wood_textures[randi_range(0, 3)]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("INTERACT"):
		queue_free()
		PlayerAutoload.player.set_wood(PlayerAutoload.player.wood + 1)
		print(PlayerAutoload.player.wood)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		hover_sprite.show()
		
		set_process(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		hover_sprite.hide()
		
		set_process(false)
