extends CharacterBody2D

var stamina : float = 300
const stamina_rate : int = 50
var speed : int = 500
var can_sprint : bool = true

@onready var hurtbox = $HurtBox
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var hurtboxshape = $HurtBox/CollisionShape2D

func _ready() -> void:
	hurtbox.connect("get_hurt", Callable(self, "_on_get_damage"))

func _physics_process(delta: float) -> void:
	get_input()
	movement()
	set_animations()
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

func set_animations() -> void:
	if velocity != Vector2.ZERO:
		sprite.play("walk")
	else:
		sprite.play("default")
	
	if velocity == Vector2.RIGHT:
		sprite.flip_h = false
	elif velocity == Vector2.LEFT:
		sprite.flip_h = true

func _on_get_damage(damage : int):
	if hurtbox.health == 0:
		set_physics_process(false)
		collision.set_deferred("disabled", true)
		hurtbox.set_deferred("monitoring", false)
		hurtboxshape.set_deferred("disabled", true)
		sprite.set_deferred("visible", false)
