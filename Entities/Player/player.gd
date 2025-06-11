extends CharacterBody2D

var stamina : int = 300
var speed : int = 500

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

func get_input() -> void:
	var input_direction = Input.get_vector("A", "D", "W", "S")
	velocity = input_direction.normalized() * speed
	
	print(stamina)
	
	if stamina >= 0:
		if Input.is_action_pressed("SPRINT"):
			stamina -= 1
			print("test2")
			speed = 750
		
		if !Input.is_action_pressed("SPRINT"):
			if stamina >= 300:
				pass
			else:
				stamina += 1
				print("test")
		
	else:
		# send ui-signal
		speed = 200
		await get_tree().create_timer(5.0).timeout
		speed = 500
		stamina = 1
	
	
