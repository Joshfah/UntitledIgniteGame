extends Node2D

@onready var sprite = $"../AnimatedSprite2D"
@onready var player : Player = $".."

var last_vertical_dir : String = "down"
var flip : bool = false

func _process(_delta: float) -> void:
	
	var x = sign(player.velocity.x)
	var y = sign(player.velocity.y)
	
	if y > 0:
		last_vertical_dir = "down"
	elif y < 0:
		last_vertical_dir = "up"
	
	if x > 0:
		flip = false
	elif x < 0:
		flip = true
	
	if x != 0 && y == 0:
		last_vertical_dir = "down"
	
	var animation : String = "walk_" + last_vertical_dir
	
	if player.velocity == Vector2.ZERO:
		animation = "idle_" + last_vertical_dir
	
	if player.has_axe:
		animation = animation + "_axe"
	
	sprite.flip_h = flip
	
	sprite.play(animation)
