class_name Player
extends CharacterBody2D

@export var stamina : float = 300
@export var stamina_rate : int = 50
@export var speed : int = 500
@export var frost_capacity := 200.0

var can_sprint : bool = true
var current_frost := 0.0: set = set_current_frost

@onready var hurtbox = $HurtBox
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var hurtboxshape = $HurtBox/CollisionShape2D
@onready var camera = $Camera2D
@onready var _frost_damage_timer := $FrostDamageTimer

func _ready() -> void:
	
	PlayerAutoload.player = self
	
	hurtbox.get_hurt.connect(_on_get_damage)
	# Wenn abgelaufen, dann Frostschaden
	_frost_damage_timer.timeout.connect(get_frost_damage)

func _process(delta: float) -> void:
	# Player erfriert nach einer Zeit
	set_current_frost(current_frost + TimeCycleAutoload.current_coldness * delta)

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

## Wenn immernoch der Frostbalken voll ist, dann Schaden nehmen und Timer neu starten
func get_frost_damage() -> void:
	if not current_frost == frost_capacity:
		return
	hurtbox.get_damage(1)
	_frost_damage_timer.start()

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

func set_current_frost(new_frost: float) -> void:
	current_frost = clamp(new_frost, 0.0, frost_capacity)
	
	if current_frost == frost_capacity and _frost_damage_timer.is_stopped():
		# Wenn frost auf Maximum, dann soll der Player jede 5sec Schaden nehmen (mit Timer)
		_frost_damage_timer.start()

func _on_get_damage():
	if hurtbox.health == 0:
		set_physics_process(false)
		collision.set_deferred("disabled", true)
		hurtbox.set_deferred("monitoring", false)
		hurtboxshape.set_deferred("disabled", true)
		sprite.set_deferred("visible", false)
