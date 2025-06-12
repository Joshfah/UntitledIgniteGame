class_name Enemy
extends CharacterBody2D

enum State {
	IDLE,
	CHASE
}

@export_range(10.0, 100.0, 0.1, "or_greater") var speed := 50.0
@export_range(0.01, 1.0, 0.01) var acceleration := 0.05

@onready var _hurt_box := $HurtBox
@onready var _nav_agent := $NavigationAgent2D
@onready var _reachable_area := $ReachableArea
@onready var _ray_cast := $RayCast2D
@onready var _path_timer := $PathTimer

var state : State = State.IDLE
var target : Player

func _ready() -> void:
	_hurt_box.no_health.connect(_die)
	_reachable_area.body_exited.connect(_on_reachable_area_body_exited)
	_nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	_path_timer.timeout.connect(_recalc_path)
	if not PlayerAutoload.player:
		await get_tree().process_frame
	target = PlayerAutoload.player

func _physics_process(_delta: float) -> void:
	_ray_cast.look_at(PlayerAutoload.player.global_position)
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if _ray_cast.get_collider():
				state = State.CHASE
				print("is chasing")
		State.CHASE:
			_chase()

func _chase() -> void:
	var direction : Vector2 = (_nav_agent.get_next_path_position() - global_position).normalized()
	var desired_velocity := direction * speed
	var steering_vector := desired_velocity - velocity
	_nav_agent.set_velocity(steering_vector)
	#print(steering_vector)

func _die() -> void:
	queue_free()

func _recalc_path() -> void:
	_nav_agent.set_target_position(target.global_position)

func _on_reachable_area_body_exited(body: Node2D) -> void:
	var player := body as Player
	if not player:
		return
	state = State.IDLE
	print("is not chasing")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	#print(round(global_position.distance_to(safe_velocity)))
	velocity += safe_velocity.limit_length(speed / 2) * acceleration
	print(safe_velocity)
	move_and_slide()
