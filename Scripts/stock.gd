extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const ICONS = "res://Assets/productIcon/"

@onready var categories_grid = $MarginContainer/MainLayout/Content/CategoryPanel/MarginContainer/VBoxContainer/SectionsGrid

func _ready() -> void:
	load_categories()

func load_categories() -> void:
	var file = FileAccess.open("res://Data/sections.json", FileAccess.READ)
	if file == null:
		return
	var sections = JSON.parse_string(file.get_as_text())
	file.close()

	for section in sections:
		var btn = CAT_BTN.instantiate()
		btn.button_text = section["name"]
		btn.button_icon = load(ICONS + section["image"])
		btn.section_id = section["id"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		btn.category_pressed.connect(_on_category_selected)
		
		categories_grid.add_child(btn)

func _on_category_selected(section_id: String) -> void:
	print("Categoría seleccionada: ", section_id)
