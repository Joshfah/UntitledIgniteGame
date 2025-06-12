class_name Player
extends CharacterBody2D

@export var stamina : float = 300
@export var stamina_rate : int = 50
@export var speed : int = 500
@export var frost_capacity := 200.0

var has_axe : bool = false
var can_sprint : bool = true
var input_direction : Vector2

@onready var hurtbox = $HurtBox
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var hurtboxshape = $HurtBox/CollisionShape2D
@onready var camera = $Camera2D

func _ready() -> void:
	
	PlayerAutoload.player = self
	
	hurtbox.get_hurt.connect(_on_get_damage)

func _physics_process(delta: float) -> void:
	get_input()
	movement()
	move_and_slide()
	
	if !can_sprint:
		return
	
	if Input.is_action_pressed("SPRINT"):
		stamina -= stamina_rate * delta
		speed = 750
	else:
		stamina += stamina_rate * delta
		speed = 500
	
	stamina = clamp(stamina, 0, 300)

func get_input() -> void:
	input_direction = Input.get_vector("A", "D", "W", "S")
	velocity = input_direction.normalized() * speed

func movement() -> void:
	if stamina <= 0:
		stamina = 1
		speed = 200
		can_sprint = false
		# send ui signal for canvas modulate
		await get_tree().create_timer(5.0).timeout
		can_sprint = true
		speed = 500

func _on_get_damage(damage : int):
	if hurtbox.health == 0:
		set_physics_process(false)
		collision.set_deferred("disabled", true)
		hurtbox.set_deferred("monitoring", false)
		hurtboxshape.set_deferred("disabled", true)
		sprite.set_deferred("visible", false)
