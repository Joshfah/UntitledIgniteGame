class_name Player
extends CharacterBody2D

var stamina : float = 300
const stamina_rate : int = 50
var speed : int = 500
var can_sprint : bool = true

func _ready() -> void:
	pass

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
	
	print(stamina)

func get_input() -> void:
	var input_direction = Input.get_vector("A", "D", "W", "S")
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
