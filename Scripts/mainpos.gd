extends Control

const CAT_BTN = preload("res://Scenes/Button/CategoryButton.tscn")
const PRODUCT_BTN = preload("res://Scenes/Button/ProductButton.tscn")
const ICONS = "res://Assets/productIcon/"
const IMAGES = "res://Assets/productImages/"

@onready var categories_grid = $MarginContainer/MainLayout/Content/ProductsPanel/MarginContainer/VBoxContainer/SectionsScroll/SectionsGrid
@onready var products_grid = $MarginContainer/MainLayout/Content/ProductsPanel/MarginContainer/VBoxContainer/ProductsScroll/ProductsGrid
@onready var cartItems =  $MarginContainer/MainLayout/Content/CartPanel/MarginContainer/VBoxContainer/CartItems

var total=0.0
var pro
var first_btn

func _ready() -> void:
	load_categories()
	first_btn = categories_grid.get_child(0)
	load_products("all", first_btn)

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
		products_grid.add_child(btn)
		
func addCart(product,quantity):
	total=0.0
	for child in cartItems.get_children():
		child.queue_free()
	var cart=ProductManager.cart
	var id=product.id
	if(cart.has(id)):
		cart[id]+=1
	else:
		cart[id] = 1
	for prod in cart:
		var label=Label.new()
		pro=ProductManager.searchProductByid(prod)
		label.text=pro.productName+" "+str(cart[prod])+"x"+str(pro.price)
		total += float(cart[prod]) * float(pro.price)
		cartItems.add_child(label)
		%total.text=str(total)
		


func _on_search_bar_text_changed(new_text: String) -> void:
	if (new_text==""):
		load_products("all", first_btn)
		return
	if current_btn!=first_btn:
		current_btn.set_selected(false)
		first_btn.set_selected(true)
	ProductManager.searchProducts(new_text)
	show_products(ProductManager.productsFiltered)
