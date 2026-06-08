extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const PRODUCT_BTN = preload("res://Scenes/Button/ProductButton.tscn")
const ICONS = "res://Assets/productIcon/"
const IMAGES = "res://Assets/productImages/"
const TICKET_SCENE = preload("res://Scenes/Ticket.tscn")

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
@onready var payment_total = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/TotalBlock/VBoxContainer/TotalAmount
@onready var btn_cash = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Methods/BtnCash
@onready var btn_card = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Methods/BtnCard
@onready var btn_buy_now = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Buy
@onready var btn_save_sale = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/HBoxContainer/BtnSaveSale
@onready var cartItemList = $MarginContainer/MainLayout/MarginContainer/Content/CartPanel/Cart/CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList
@onready var paid_label = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Paid
@onready var change_label = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Change

var first_btn
var paymentSelect=""
var save=false


func _ready() -> void:
	load_categories()
	first_btn = categories_grid.get_child(0)
	load_products("all", first_btn)
	username_label.text = ProductManager.current_user
	_set_active_tab(btn_sales)
	payment_total.text = "0.00 €"
	cartTSCN.total_changed.connect(_on_cart_total_changed)
	disableButtons()
	if ProductManager.cart!=null:
		loadCart()
	if save==true:
		print('UwU')
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
var current_total: float = 0.0

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
	
func _on_paid_input_text_changed(_new_text: String) -> void:
	_update_change()
	
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
	
func _update_change() -> void:
	var paid = float(paid_input.text) if paid_input.text != "" else 0.0
	var change = paid - current_total
	change_amount.text = "%.2f €" % max(change, 0.0)
	disableButtons()

func _on_cart_total_changed(amount: float) -> void:
	current_total = amount
	payment_total.text = "%.2f €" % amount
	_update_change()
	
func disableButtons():
	if paymentSelect == "":
		btn_buy_now.disabled=true
	elif paymentSelect == "Cash":
		var paid: float
		if paid_input.text != "":
			paid = float(paid_input.text)
		else:
			paid = 0.0
		btn_buy_now.disabled = paid < current_total
	else:
		btn_buy_now.disabled = false
	
func _on_sales_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")

func _on_history_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/SalesHistory.tscn")

func _on_stock_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/Stock.tscn")

func loadCart():
	var cart = ProductManager.cart
	
	if cart != null and not cart.is_empty():
		save=true
		var product = ProductManager.searchProductByid(int( cart.keys()[0]))
		cartTSCN.add_product(product, cart)
		
func _on_buy_pressed() -> void:
	save=false
	ProductManager.update_stock_after_sale()
	ProductManager.save_sale(paymentSelect)
	ProductManager.cart.clear()
	cartTSCN.add_product(null, {})
	for child in cartItemList.get_children():
		child.queue_free()
	paid_input.text = ""
	change_amount.text = "0.00 €"
	load_products(current_btn.section_id if current_btn else "all", current_btn)

func _on_btn_save_sale_pressed() -> void:
	ProductManager.save_sale("SAVE")


func _on_btn_cash_pressed() -> void:
	paymentSelect="Cash"
	disableButtons()
	paid_label.visible = true
	paid_input.visible = true
	change_label.visible = true
	change_amount.visible = true


func _on_btn_card_pressed() -> void:
	paymentSelect="Card"
	disableButtons()
	paid_label.visible = false
	paid_input.visible = false
	change_label.visible = false
	change_amount.visible = false
	
func _on_ticket_pressed() -> void:
	var popup = TICKET_SCENE.instantiate()
	var layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	layer.add_child(popup)
	popup.tree_exiting.connect(layer.queue_free)


func _on_btn_logout_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Login.tscn")


func _on_btn_cancel_pressed() -> void:
	ProductManager.cart.clear()
	var file = FileAccess.open("user://historysales.json", FileAccess.READ)
	var sales = JSON.parse_string(file.get_as_text())
	file.close()
	
	if sales == null:
		return

	for i in range(sales.size()):
		if int(sales[i].get("sale_id")) == ProductManager.saveSaleId:
			sales.remove_at(i)
			break

	var write_file = FileAccess.open("user://historysales.json", FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(sales, "\t"))
		write_file.close()
		
	cartTSCN.add_product(null, {})
	for child in cartItemList.get_children():
		child.queue_free()
	paid_input.text = ""
	change_amount.text = "0.00 €"
	
