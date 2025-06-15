class_name Enemy
extends CharacterBody2D

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK
}

@export_range(10.0, 100.0, 0.1, "or_greater") var normal_speed := 50.0
@export_range(0.01, 1.0, 0.01) var acceleration := 0.05
@export_range(1.0, 50.0, 0.5) var max_patrol_delay := 15.0
@export_range(10.0, 300.0, 0.1) var max_patrol_distance := 192.0
@export_group("Attack", "attack")
## Der Delay bevor die Attacke losgeht
@export_range(0.1, 1.0, 0.1, "or_greater") var attack_prepare_duration := 0.5
@export_range(0.1, 5.0, 0.1) var attack_cooldown := 1.0
## Die Sprunggeschwindigkeit
@export_range(50.0, 500.0, 0.5) var attack_dash_speed := 400.0
## Die Sprungreichweite
@export_range(10.0, 100.0, 0.1) var attack_dash_range := 50.0
## Nach der Attacke wird verlangsamt und gewinnt nach einer kurze Zeit wieder an die normale Geschwindigkeit (normal_speed)
@export_range(10.0, 50.0, 0.1) var attack_penalty_speed := 10.0

@onready var _hurt_box := $HurtBox
@onready var _hit_box := $HitBox
@onready var _nav_agent := $NavigationAgent2D
@onready var _reachable_area := $ReachableArea
@onready var _attack_area := $AttackArea
@onready var _ray_cast := $RayCast2D
@onready var _path_timer := $PathTimer
@onready var _prepare_timer := $PrepareTimer
@onready var _cooldown_timer := $AttackCooldownTimer
@onready var _patrol_timer := $PatrolTimer
@onready var _animated_sprite := $AnimatedSprite2D
# SFX
@onready var _attack_sfx := $SFX/AttackSFX
@onready var _die_sfx := $SFX/DieSFX
@onready var _hit_sfx := $SFX/HitSFX

var state : State = State.IDLE
var target : Player
var speed := 0.0
var is_preparing_to_attack := false

var _jump_direction : Vector2
var _distance_reach := 0.0

func _ready() -> void:
	# connections
	_hurt_box.no_health.connect(_die)
	_hurt_box.get_hurt.connect(_on_hurt_box_get_hurt)
	_reachable_area.body_exited.connect(_on_reachable_area_body_exited)
	_attack_area.body_entered.connect(_on_attack_area_body_entered)
	_nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	_path_timer.timeout.connect(_recalc_path)
	_cooldown_timer.timeout.connect(_recover)
	_patrol_timer.timeout.connect(_start_patrol)
	# Preset
	speed = normal_speed
	_prepare_timer.wait_time = attack_prepare_duration
	_cooldown_timer.wait_time = attack_cooldown
	randomize()
	_patrol_timer.start(randf() * max_patrol_delay)
	if not PlayerAutoload.player:
		await get_tree().process_frame
	target = PlayerAutoload.player

func _physics_process(delta: float) -> void:
	_ray_cast.look_at(PlayerAutoload.player.global_position)
	_animated_sprite.flip_h = velocity.x > 0
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if _ray_cast.get_collider() is Player:
				state = State.CHASE
				_play("run")
				print("is chasing")
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()
		State.ATTACK:
			_attack(delta)


func _chase() -> void:
	var direction : Vector2 = (_nav_agent.get_next_path_position() - global_position).normalized()
	var desired_velocity := direction * speed
	var steering_vector := desired_velocity - velocity
	_nav_agent.set_velocity(steering_vector)

func _attack(delta: float) -> void:
	if not _prepare_timer.is_stopped() or not _cooldown_timer.is_stopped():
		return
	velocity = _jump_direction * attack_dash_speed
	move_and_slide()
	_distance_reach += attack_dash_speed * delta
	print(_cooldown_timer.time_left)
	if _distance_reach > attack_dash_range:
		velocity = Vector2.ZERO
		_distance_reach = 0.0
		_jump_direction = Vector2.ZERO
		
		_cooldown_timer.start()
		#state = State.CHASE
		_play("idle")

func _patrol() -> void:
	_chase()
	if _nav_agent.is_target_reached():
		_patrol_timer.start(randf() * max_patrol_delay)
		_play("idle")
		state = State.IDLE
	if _ray_cast.get_collider() is Player:
		state = State.CHASE
		_play("run")
		print("is chasing")

func _start_patrol() -> void:
	if not state == State.IDLE:
		return
	randomize()
	var random_direction_vector := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var random_position := random_direction_vector * max_patrol_distance * randf() + global_position
	_nav_agent.set_target_position(random_position)
	
	_play("run")
	state = State.PATROL

func _recover() -> void:
	state = State.CHASE
	_play("run")
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	speed = attack_penalty_speed
	tween.tween_property(self, "speed", normal_speed, 0.5)
	is_preparing_to_attack = false

func _play(animation: String) -> void:
	if _animated_sprite.is_playing():
		_animated_sprite.stop()
	_animated_sprite.play(animation)

func _die() -> void:
	set_physics_process(false)
	_hurt_box.set_deferred("monitorable", false)
	_hit_box.set_deferred("monitoring", false)
	_animated_sprite.hide()
	_die_sfx.play()
	await _die_sfx.finished
	queue_free()

func _recalc_path() -> void:
	if not state == State.CHASE:
		return
	_nav_agent.set_target_position(target.global_position)

func _on_hurt_box_get_hurt() -> void:
	_hit_sfx.play()
	_animated_sprite.modulate = Color(1.0, 0.0, 0.0)
	var tween := create_tween()
	tween.tween_property(_animated_sprite, "modulate", Color(1.0, 1.0, 1.0), 1.0)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body is Player or is_preparing_to_attack:
		return
	_jump_direction = (target.global_position - global_position).normalized()
	is_preparing_to_attack = true
	_prepare_timer.start()
	velocity = Vector2.ZERO
	#_play("prepare")
	_play("attack")
	state = State.ATTACK
	await _prepare_timer.timeout
	_attack_sfx.play()

func _on_reachable_area_body_exited(body: Node2D) -> void:
	var player := body as Player
	if not player:
		return
	state = State.IDLE
	_play("idle")
	print("is not chasing")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if is_preparing_to_attack:
		return
	velocity += safe_velocity.limit_length(normal_speed / 2) * acceleration
	move_and_slide()
