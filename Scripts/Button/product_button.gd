extends PanelContainer

signal productPressed(pro,quantity)

@onready var label = $Button/VBoxContainer/Label
@onready var icon = $Button/VBoxContainer/TextureRect
@onready var price = $Button/VBoxContainer/Label2

@export var button_text: String
@export var price_text: String
@export var button_icon: Texture2D
@export var icon_size: Vector2 = Vector2(40, 40)
var pro
var quantity=0

func _ready():
	label.text = button_text
	price.text = price_text + " € / ud"
	icon.texture = button_icon
	icon.custom_minimum_size = icon_size
	
	


func _on_button_pressed() -> void:
	productPressed.emit(pro, quantity)
