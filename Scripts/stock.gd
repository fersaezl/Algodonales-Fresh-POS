extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const ICONS = "res://Assets/productIcon/"

@onready var categories_grid = $MarginContainer/MainLayout/MarginContainer/Content/CategoryPanel/MarginContainer/VBoxContainer/SectionsGrid
@onready var btn_sales = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Sales
@onready var btn_history = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/History
@onready var btn_stock = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Stock
@onready var username_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/UserName
@onready var datetime_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/DateTime

func _ready() -> void:
	load_categories()
	username_label.text = ProductManager.current_user
	_set_active_tab(btn_stock)

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
		
func _process(_delta) -> void:
	var t = Time.get_datetime_dict_from_system()
	datetime_label.text = "%02d/%02d/%04d  %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]

func _on_category_selected(section_id: String) -> void:
	print("Categoría seleccionada: ", section_id)


func _set_active_tab(active_btn: Button) -> void:
	for btn in [btn_sales, btn_history, btn_stock]:
		btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(0.149, 0.6, 0.149, 0.3)
	active_style.corner_radius_top_left = 8
	active_style.corner_radius_top_right = 8
	active_style.corner_radius_bottom_right = 8
	active_style.corner_radius_bottom_left = 8
	active_btn.add_theme_stylebox_override("normal", active_style)

func _on_sales_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")

func _on_history_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/SalesHistory.tscn")

func _on_stock_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/Stock.tscn")
