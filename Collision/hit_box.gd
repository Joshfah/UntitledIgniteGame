class_name HitBox
extends Area2D

@export_range(0, 20, 1) var damage := 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var hurt_box = area as HurtBox
	if not hurt_box:
		return
	hurt_box.get_damage(damage)
