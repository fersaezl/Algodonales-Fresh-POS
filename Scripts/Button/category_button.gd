extends PanelContainer

signal category_pressed(section_id: String, btn: PanelContainer)

@onready var label = $Button/VBoxContainer/CategoryLabel
@onready var icon = $Button/VBoxContainer/CategoryImage

@export var button_text: String
@export var button_icon: Texture2D
@export var icon_size: Vector2 = Vector2(64, 64)
@export var section_id: String

func _ready():
	label.text = button_text
	icon.texture = button_icon
	icon.custom_minimum_size = icon_size

func _on_button_pressed() -> void:
	category_pressed.emit(section_id, self)

func set_selected(value: bool) -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.bg_color = Color(0.32, 0.70, 0.30, 1) if value else Color(1, 1, 1, 1)
	add_theme_stylebox_override("panel", style)
