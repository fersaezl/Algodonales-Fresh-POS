extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const PRODUCT_BTN = preload("res://Scenes/Button/ProductButton.tscn")
const ICONS = "res://Assets/productIcon/"
const IMAGES = "res://Assets/productImages/"

@onready var categories_grid = $MarginContainer/MainLayout/Content/ProductsPanel/MarginContainer/VBoxContainer/SectionsScroll/SectionsGrid
@onready var products_grid = $MarginContainer/MainLayout/Content/ProductsPanel/MarginContainer/VBoxContainer/ProductsScroll/ProductsGrid

func _ready() -> void:
	load_categories()
	load_products("all")

func load_categories() -> void:
	var file = FileAccess.open("res://Data/sections.json", FileAccess.READ)
	if file == null:
		push_error("The file sections.json could not be opened")
		return
	var sections = JSON.parse_string(file.get_as_text())
	file.close()

	for section in sections:
		var btn = CAT_BTN.instantiate()
		btn.button_text = section["name"]
		btn.button_icon = load(ICONS + section["image"])
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		categories_grid.add_child(btn)

func load_products(section_id: String) -> void:
	for child in products_grid.get_children():
		child.queue_free()

	if section_id == "all":
		show_products(ProductManager.products)
	else:
		ProductManager.productsSection(section_id)
		show_products(ProductManager.productsFiltered)

func show_products(product_list: Array) -> void:
	for product in product_list:
		var btn = PRODUCT_BTN.instantiate()
		btn.button_text = product["productName"]
		btn.price_text = str(product["price"])
		btn.button_icon = load(IMAGES + product["image"])
		products_grid.add_child(btn)
