extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const FONT = preload("res://Assets/Fonts/Helvetica-Bold.ttf")
const FONT_COLOR = Color(0.1764706, 0.3019608, 0.1764706, 1)
const BORDER_COLOR = Color(0.8980392, 0.92941177, 0.8980392, 1)
const ICONS = "res://Assets/productIcon/"
const IMAGES = "res://Assets/productImages/"

@onready var categories_grid = $MarginContainer/MainLayout/MarginContainer/Content/CategoryPanel/MarginContainer/VBoxContainer/SectionsGrid
@onready var btn_sales = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Sales
@onready var btn_history = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/History
@onready var btn_stock = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Stock
@onready var username_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/UserName
@onready var datetime_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/DateTime
@onready var products_list = $MarginContainer/MainLayout/MarginContainer/Content/ProductContainer/MarginContainer/VBoxContainer/ScrollContainer/ProductsList

@onready var total_products_label = $MarginContainer/MainLayout/MarginContainer/Content/StockPanel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/TotalProducts/MarginContainer/VBoxContainer/TotalProductsLabel
@onready var low_stock_label = $MarginContainer/MainLayout/MarginContainer/Content/StockPanel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/LowStock/MarginContainer/VBoxContainer/LowStockProductsLabel
@onready var out_of_stock_label = $MarginContainer/MainLayout/MarginContainer/Content/StockPanel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/NoStock/MarginContainer/VBoxContainer/NoStockProductsLabel
@onready var inventory_value_label = $MarginContainer/MainLayout/MarginContainer/Content/StockPanel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/InventoryValue/MarginContainer/VBoxContainer/InventoryLabel

var current_btn = null
var current_stock_filter: String = "all"
var current_section_id: String = "all"

func _ready() -> void:
	load_categories()
	username_label.text = ProductManager.current_user
	_set_active_tab(btn_stock)
	
	_update_stock_counters()
	
	var first = categories_grid.get_child(0)
	_on_category_selected("all", first)

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

func _on_category_selected(section_id: String, btn = null) -> void:
	if current_btn:
		current_btn.set_selected(false)
	current_btn = btn
	if btn:
		btn.set_selected(true)
	current_section_id = section_id
	_apply_filters()

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
	
func show_products(product_list: Array) -> void:
	for child in products_list.get_children():
		child.queue_free()
		
	for product in product_list:
		var panel = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color            = Color(1, 1, 1, 1)
		style.border_width_bottom = 1
		style.border_color        = BORDER_COLOR
		style.content_margin_top    = 6.0
		style.content_margin_bottom = 6.0
		style.content_margin_left   = 0.0
		style.content_margin_right  = 0.0
		panel.add_theme_stylebox_override("panel", style)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 0)
		
		var img_wrapper = Control.new()
		img_wrapper.custom_minimum_size = Vector2(35, 35)
		img_wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		img_wrapper.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		img_wrapper.clip_contents = true
		var img = TextureRect.new()
		img.texture      = load(IMAGES + product["image"])
		img.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.anchor_right  = 1.0
		img.anchor_bottom = 1.0
		img_wrapper.add_child(img)
		row.add_child(img_wrapper)
		
		var name_lbl = Label.new()
		name_lbl.text = product["productName"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		name_lbl.add_theme_font_override("font", FONT)
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", FONT_COLOR)
		row.add_child(name_lbl)
		
		var cat_lbl = Label.new()
		cat_lbl.text = _get_section_name(product["section"])
		cat_lbl.custom_minimum_size   = Vector2(90, 0)
		cat_lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cat_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		cat_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
		cat_lbl.add_theme_font_override("font", FONT)
		cat_lbl.add_theme_font_size_override("font_size", 13)
		cat_lbl.add_theme_color_override("font_color", FONT_COLOR)
		row.add_child(cat_lbl)
		
		var stock_val = int(product["stock"])
		var status    = _get_status(stock_val)
		var stock_lbl = Label.new()
		stock_lbl.text = str(stock_val) + " ud"
		stock_lbl.custom_minimum_size   = Vector2(70, 0)
		stock_lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		stock_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		stock_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
		stock_lbl.add_theme_font_override("font", FONT)
		stock_lbl.add_theme_font_size_override("font_size", 13)
		stock_lbl.add_theme_color_override("font_color", _get_status_color(status))
		row.add_child(stock_lbl)
		
		var badge_wrap = CenterContainer.new()
		badge_wrap.custom_minimum_size   = Vector2(90, 0)
		badge_wrap.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		badge_wrap.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		badge_wrap.add_child(_make_status_badge(status))
		row.add_child(badge_wrap)
		
		var valor_lbl = Label.new()
		valor_lbl.text = "%.2f €" % (product["price"] * product["stock"])
		valor_lbl.custom_minimum_size   = Vector2(70, 0)
		valor_lbl.size_flags_horizontal = Control.SIZE_SHRINK_END
		valor_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
		valor_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
		valor_lbl.add_theme_font_override("font", FONT)
		valor_lbl.add_theme_font_size_override("font_size", 13)
		valor_lbl.add_theme_color_override("font_color", FONT_COLOR)
		row.add_child(valor_lbl)
		
		panel.add_child(row)
		products_list.add_child(panel)
		
func _get_section_name(section_id: String) -> String:
	for section in ProductManager.sections:
		if section["id"] == section_id:
			return section["name"]
	return section_id
	
func _get_status(stock: int) -> String:
	if stock == 0:
		return "OUT"
	elif stock <= 10:
		return "LOW"
	return "OK"
	
func _get_status_color(status: String) -> Color:
	match status:
		"OK": return Color(0.1, 0.6, 0.1, 1)
		"LOW": return Color(0.85, 0.6, 0.0, 1)
		"OUT": return Color(0.85, 0.1, 0.1, 1)
	return Color.BLACK

func _make_status_badge(status: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(40, 22)
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	match status:
		"OK": style.bg_color = Color(0.85, 0.97, 0.85, 1)
		"LOW": style.bg_color = Color(1.0, 0.95, 0.8, 1)
		"OUT": style.bg_color = Color(1.0, 0.85, 0.85, 1)
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var lbl = Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.text = status
	lbl.add_theme_color_override("font_color", _get_status_color(status))
	lbl.add_theme_font_size_override("font_size", 12)
	panel.add_child(lbl)
	return panel
	
func _apply_filters() -> void:
	var base = ProductManager.products
	
	if current_section_id != "all":
		base = base.filter(func(p): return p["section"] == current_section_id)
	match current_stock_filter:
		"high": base = base.filter(func(p): return int(p["stock"]) > 10)
		"low":  base = base.filter(func(p): return int(p["stock"]) > 0 and int(p["stock"]) <= 10)
		"out":  base = base.filter(func(p): return int(p["stock"]) == 0)
			
	show_products(base)

func _on_sales_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")

func _on_history_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/SalesHistory.tscn")

func _on_stock_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/Stock.tscn")

func _on_btn_all_pressed() -> void:
	current_stock_filter = "all"
	_apply_filters()

func _on_btn_high_pressed() -> void:
	current_stock_filter = "high"
	_apply_filters()

func _on_btn_low_pressed() -> void:
	current_stock_filter = "low"
	_apply_filters()

func _on_btn_out_pressed() -> void:
	current_stock_filter = "out"
	_apply_filters()

func _update_stock_counters() -> void:
	var all_products = ProductManager.products
	
	var total_count = all_products.size()
	var low_count = 0
	var out_count = 0
	var total_value = 0.0
	
	for product in all_products:
		var stock = int(product["stock"])
		var price = float(product["price"])
		
		total_value += price * stock
		
		if stock == 0:
			out_count += 1
		elif stock <= 10:
			low_count += 1
			
	total_products_label.text = str(total_count)
	low_stock_label.text = str(low_count)
	out_of_stock_label.text = str(out_count)
	
	inventory_value_label.text = "%.2f €" % total_value
