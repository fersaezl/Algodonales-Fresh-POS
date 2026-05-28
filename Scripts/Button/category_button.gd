extends PanelContainer

@onready var label = $Button/VBoxContainer/CategoryLabel
@onready var icon = $Button/VBoxContainer/CategoryImage

@export var button_text: String
@export var button_icon: Texture2D
@export var icon_size: Vector2 = Vector2(64, 64)

func _ready():
	label.text = button_text
	icon.texture = button_icon
	icon.custom_minimum_size = icon_size
