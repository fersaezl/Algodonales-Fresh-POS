extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const PRODUCT_BTN = preload("res://Scenes/Button/ProductButton.tscn")
const ICONS = "res://Assets/productIcon/"
const IMAGES = "res://Assets/productImages/"

@onready var categories_grid = $MarginContainer/MainLayout/MarginContainer/Content/ProductsPanel/MarginContainer/VBoxContainer/SectionsScroll/SectionsGrid
@onready var products_grid = $MarginContainer/MainLayout/MarginContainer/Content/ProductsPanel/MarginContainer/VBoxContainer/ProductsScroll/ProductsGrid
@onready var cartTSCN = $MarginContainer/MainLayout/MarginContainer/Content/CartPanel/Cart
@onready var username_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/UserName
@onready var datetime_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/DateTime
@onready var btn_sales = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Sales
@onready var btn_history = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/History
@onready var btn_stock = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Stock
@onready var paid_input = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/PaidInput
@onready var change_amount = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/ChangeAmount

var first_btn

func _ready() -> void:
	load_categories()
	first_btn = categories_grid.get_child(0)
	load_products("all", first_btn)
	username_label.text = ProductManager.current_user
	_set_active_tab(btn_sales)

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
		btn.section_id = section["id"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.category_pressed.connect(load_products)
		categories_grid.add_child(btn)

var current_btn = null

func load_products(section_id: String, btn = null) -> void:
	if current_btn:
		current_btn.set_selected(false)
	current_btn = btn
	if btn: 
		btn.set_selected(true)
	
	for child in products_grid.get_children():
		child.queue_free()

	if section_id == "all":
		show_products(ProductManager.products)
	else:
		ProductManager.productsSection(section_id)
		show_products(ProductManager.productsFiltered)

func show_products(product_list: Array) -> void:
	
	for child in products_grid.get_children():
		child.queue_free()
	for product in product_list:
		var btn = PRODUCT_BTN.instantiate()
		btn.button_text = product["productName"]
		btn.price_text = str(product["price"])
		btn.button_icon = load(IMAGES + product["image"])
		btn.pro=product
		btn.productPressed.connect(addCart)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		products_grid.add_child(btn)
		
func addCart(product, quantity):
	var cart = ProductManager.cart
	var id = product.id
	if cart.has(id):
		cart[id] += 1
	else:
		cart[id] = 1
	cartTSCN.add_product(product, cart)
	
func _on_paid_input_text_changed(new_text: String) -> void:
	var paid = float(new_text) if new_text != "" else 0.0
	var total = 0.0
	for prod_id in ProductManager.cart:
		var pro = ProductManager.searchProductByid(prod_id)
		if pro:
			total += float(pro.price) * ProductManager.cart[prod_id]
		var change = paid - total
		change_amount.text = "%.2f €" % max(change, 0.0)
	
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

func _on_search_bar_text_changed(new_text: String) -> void:
	if (new_text==""):
		load_products("all", first_btn)
		return
	if current_btn!=first_btn:
		current_btn.set_selected(false)
		first_btn.set_selected(true)
	ProductManager.searchProducts(new_text)
	show_products(ProductManager.productsFiltered)

func _process(_delta) -> void:
	var t = Time.get_datetime_dict_from_system()
	datetime_label.text = "%02d/%02d/%04d  %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]


func _on_sales_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")

func _on_history_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/SalesHistory.tscn")

func _on_stock_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/Stock.tscn")
