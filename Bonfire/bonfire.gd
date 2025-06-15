class_name Bonfire
extends StaticBody2D

## die Scale-Größe der Flamme, wenn fuel_left auf Maximum ist
@export_range(0.5, 4.0, 0.1) var initial_flame_scale := 2.0
@export var ignite_particles_scene : PackedScene
@export_group("Fuel")
@export_range(50.0, 2000.0, 0.5, "or_greater") var max_fuel := 1500.0
@export_range(1.0, 200.0, 0.5, "or_greater") var recharge_rate := 50.0
@export_range(10.0, 400.0, 0.5) var fuel_power := 100.0
@export_group("Heat")
## Wie schnell der Bonfire den Player aufwärmt (pro Sekunde)
@export_range(1.0, 200.0, 0.1) var heat_power := 50.0
@export_range(8.0, 32.0, 0.1) var min_radius := 16.0
@export_range(64.0, 128.0, 0.1) var max_radius := 80.0


@onready var _flame_sprite := $Flame
@onready var _heat_area := $HeatArea
@onready var _heat_collision_shape := $HeatArea/CollisionShape2D
@onready var _flame_particles := $FlameParticles
@onready var _light := $PointLight2D

## die Lebenskraft - wenn 0, dann erlischt es
var fuel_left : float: set = set_fuel_left
## das Holz, was noch verbrannt werden kann
var fuel_storage := 0.0
## Der aktuelle Größe von der Hitze
var current_heat_size := 16.0
var is_player_nearby := false

func _ready() -> void:
	_heat_area.body_entered.connect(_on_heat_area_body_entered)
	_heat_area.body_exited.connect(_on_heat_area_body_exited)
	set_fuel_left(max_fuel / 2.0)
	_flame_sprite.play("default")

func _process(delta: float) -> void:
	# wenn was übrig ist, dann ins fuel_left adden
	if fuel_storage > 0:
		fuel_storage -= recharge_rate * delta
		fuel_storage = clamp(fuel_storage, 0, INF)
		set_fuel_left(fuel_left + recharge_rate * delta)
	# das Feuer wird immer kleiner, je nachdem wie kalt Draußen ist
	set_fuel_left(fuel_left - TimeCycleAutoload.current_coldness * delta)
	# wenn Player in der Nähe ist, dann wärmen
	if is_player_nearby:
		PlayerAutoload.player.current_frost -= heat_power * delta

# TEST
func _input(event: InputEvent) -> void:
	var player := PlayerAutoload.player
	if event.is_action_pressed("INTERACT") and is_player_nearby and player.wood > 0:
		player.set_wood(player.wood - 1)
		add_fuel(fuel_power)

func set_fuel_left(new_fuel: float) -> void:
	fuel_left = clamp(new_fuel, 0.0, max_fuel)
	# Größe der Flamme
	var current_scale := fuel_left * initial_flame_scale / max_fuel
	set_particle_scale(current_scale)
	#_flame_sprite.scale = Vector2(current_scale, current_scale)
	# Größe der Hitze
	var current_heat_factor := fuel_left / max_fuel
	var true_heat_size : float = clamp(current_heat_factor * max_radius, min_radius, max_radius)
	var circle_shape := _heat_collision_shape.shape as CircleShape2D
	circle_shape.radius = true_heat_size
	_light.texture_scale = lerp(0.0, 0.25, current_heat_factor)

func set_particle_scale(new_scale: float) -> void:
	var counter := 0
	for particle in _flame_particles.get_children():
		var particle_process_material := particle.process_material as ParticleProcessMaterial
		var actual_scale := new_scale / ((counter % 2) + 1) as float
		particle_process_material.scale_min = actual_scale
		particle_process_material.scale_max = actual_scale
		counter += 1

func add_fuel(fuel: float) -> void:
	fuel_storage += fuel
	# Particles
	var ignite_particles := ignite_particles_scene.instantiate() as GPUParticles2D
	_flame_particles.add_child(ignite_particles)
	ignite_particles.emitting = true
	ignite_particles.finished.connect(ignite_particles.queue_free)

func _on_heat_area_body_entered(_body: Node2D) -> void:
	if not _body is Player:
		return
	is_player_nearby = true
	print("Player entered")

func _on_heat_area_body_exited(_body: Node2D) -> void:
	if not _body is Player:
		return
	is_player_nearby = false
	print("Player exited")
