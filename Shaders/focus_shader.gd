class_name FocusShaderUI
extends ColorRect

func _ready() -> void:
	show()

func set_line_density(density: float) -> void:
	var clamped_density : float = clamp(density, 0.0, 1.0)
	material.set_shader_parameter("line_density", clamped_density)
