extends Control

@onready var items_list = $CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList
const IMAGES = "res://Assets/productImages/"
var total=0.0
var productsAdded=0


func add_product(product, cart):
	total = 0.0
	for child in items_list.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	for prod_id in cart:
		var pro = ProductManager.searchProductByid(prod_id)
		var subtotal = float(cart[prod_id]) * float(pro.price)
		var item = HBoxContainer.new()

		var image = TextureRect.new()
		image.texture = load(IMAGES + pro.image)
		image.custom_minimum_size = Vector2(64, 64)
		image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		

		var label = Label.new()
		label.text = pro.productName + " x" + str(cart[prod_id]) + "  " + str(subtotal) + "€"

		item.add_child(image)
		item.add_child(label)
		items_list.add_child(item)
		total += subtotal

	%TotalAmount.text = str(total)
	%Badge.text = str(Cart2.productsAdded)

func _on_clear_btn_pressed() -> void:
	ProductManager.cart.clear()
	for child in items_list.get_children():
		child.queue_free()
	%TotalAmount.text=str(0)
	%Badge.text=str(0)
