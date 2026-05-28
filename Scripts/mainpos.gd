extends Control

const BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const ICONS = "res://Assets/productIcon/"

@onready var categories_grid = $MarginContainer/MainLayout/Content/ProductsPanel/MarginContainer/VBoxContainer/ProductsScroll/ProductsGrid

func _ready() -> void:
	load_categories()

func load_categories() -> void:
	var file = FileAccess.open("res://Data/sections.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir sections.json")
		return
	var sections = JSON.parse_string(file.get_as_text())
	file.close()

	for section in sections:
		var btn = BTN.instantiate()
		btn.button_text = section["name"]
		btn.button_icon = load(ICONS + section["image"])
		categories_grid.add_child(btn)
