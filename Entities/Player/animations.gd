extends Node2D

@onready var sprite = $"../AnimatedSprite2D"
@onready var player : Player = $".."
@onready var hitbox = $"../HitBox"

var last_facing_dir : Vector2
var last_vertical_dir : String = "down"
var flip : bool = false
var hitting : bool = false

func _process(_delta: float) -> void:
	
	var x = sign(player.velocity.x)
	var y = sign(player.velocity.y)
	
	if y > 0 && x == 0:
		last_vertical_dir = "down"
	elif y < 0 && x == 0:
		last_vertical_dir = "up"
	
	last_facing_dir.x = x
	last_facing_dir.y = y
	
	if x > 0:
		flip = false
	elif x < 0:
		flip = true
	
	if x != 0 && y == 0:
		last_vertical_dir = "down"
	
	print(last_facing_dir)
	
	var animation : String
	if player.velocity != Vector2.ZERO && !hitting:
		animation  = "walk_" + last_vertical_dir
	
	if player.velocity == Vector2.ZERO && !hitting:
		animation = "idle_" + last_vertical_dir
	
	if player.has_axe:
		animation = animation + "_axe"
		
		set_hitbox_pos()
		
		if Input.is_action_just_pressed("HIT"):
			hitting = true
			
			player.set_physics_process(false)
			
			print("hit_" + last_vertical_dir)
			sprite.play("hit_" + last_vertical_dir)
			
			await sprite.animation_finished
			
			player.set_physics_process(true)
			hitting = false
	sprite.flip_h = flip
	
	if animation == "_axe":
		animation = ""
	
	sprite.play(animation)

func set_hitbox_pos() -> void:
	if last_facing_dir == Vector2.RIGHT:
		hitbox.position = Vector2(10, 0)
	elif last_facing_dir == Vector2.LEFT:
		hitbox.position = Vector2(-10, 0)
	elif last_facing_dir == Vector2.UP:
		hitbox.position = Vector2(0, -11)
	elif last_facing_dir == Vector2.DOWN:
		hitbox.position = Vector2(0, 12)
