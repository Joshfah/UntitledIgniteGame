class_name Bonfire
extends StaticBody2D

@export_range(50.0, 2000.0, 0.5, "or_greater") var max_fuel := 1500.0
@export_range(1.0, 200.0, 0.5, "or_greater") var recharge_rate := 50.0
## Wie schnell der Bonfire den Player aufwärmt (pro Sekunde)
@export_range(1.0, 200.0, 0.1) var heat_power := 50.0
## die Scale-Größe der Flamme, wenn fuel_left auf Maximum ist
@export_range(0.5, 4.0, 0.1) var initial_flame_scale := 2.0

@onready var _flame_sprite := $Flame

## die Lebenskraft - wenn 0, dann erlischt es
var fuel_left : float: set = set_fuel_left
## das Holz, was noch verbrannt werden kann
var fuel_storage := 0.0
var is_player_nearby := false

func _ready() -> void:
	set_fuel_left(max_fuel / 2.0)

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
		PlayerAutoload.player.current_frost += heat_power * delta

# TEST
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		add_fuel(200.0)

func set_fuel_left(new_fuel: float) -> void:
	fuel_left = clamp(new_fuel, 0.0, max_fuel)
	var current_scale := fuel_left * initial_flame_scale / max_fuel
	_flame_sprite.scale = Vector2(current_scale, current_scale)

func add_fuel(fuel: float) -> void:
	fuel_storage += fuel
