extends Control

@export var tax_rate: float = 0.21
@export var discount_popup : CanvasLayer
var discount: float = 0.0

@onready var items_list = $CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList

const IMAGES       = "res://Assets/productImages/"
const FONT         = preload("res://Assets/Fonts/Helvetica-Bold.ttf")
const FONT_COLOR   = Color(0.1764706, 0.3019608, 0.1764706, 1)
const BORDER_COLOR = Color(0.8980392, 0.92941177, 0.8980392, 1)

func add_product(_product, cart: Dictionary) -> void:
	await _refresh_display(cart)

func _on_edit_discount_pressed() -> void:
	if discount_popup:
		discount_popup.open()

func _on_discount_applied(amount: float) -> void:
	discount = min(amount, _get_subtotal())
	_update_footer()

func _update_footer() -> void:
	var subtotal = _get_subtotal()
	var tax      = (subtotal - discount) * tax_rate
	var total    = subtotal - discount + tax
	%SubtotalAmount.text = "%.2f €" % subtotal
	%DiscountAmount.text = "%.2f €" % discount
	%TaxAmount.text      = "%.2f €" % tax
	%TotalAmount.text    = "%.2f €" % total

func _get_subtotal() -> float:
	var total := 0.0
	for prod_id in ProductManager.cart:
		var pro = ProductManager.searchProductByid(prod_id)
		if pro:
			total += float(pro.price) * ProductManager.cart[prod_id]
	return total

func _refresh_display(cart: Dictionary) -> void:
	for child in items_list.get_children():
		child.queue_free()
	await get_tree().process_frame

	var grand_total := 0.0
	var total_qty   := 0

	for prod_id in cart:
		var pro = ProductManager.searchProductByid(prod_id)
		if pro == null:
			continue
		var qty: int        = cart[prod_id]
		var subtotal: float = float(pro.price) * qty
		grand_total += subtotal
		total_qty   += qty
		_build_row(prod_id, pro, qty, subtotal)

	%Badge.text = str(total_qty)
	_update_footer()

func _build_row(prod_id, pro, qty: int, subtotal: float) -> void:
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
	img_wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	img_wrapper.clip_contents = true

	var img = TextureRect.new()
	img.texture      = load(IMAGES + pro.image)
	img.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	img.anchor_right  = 1.0
	img.anchor_bottom = 1.0
	img.offset_left   = 0
	img.offset_top    = 0
	img.offset_right  = 0
	img.offset_bottom = 0
	img_wrapper.add_child(img) 

	var name_lbl = Label.new()
	name_lbl.text                  = pro.productName
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	name_lbl.add_theme_font_override("font", FONT)
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", FONT_COLOR)

	var price_lbl = Label.new()
	price_lbl.text                  = "%.2f €" % float(pro.price)
	price_lbl.custom_minimum_size   = Vector2(80, 0)
	price_lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	price_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	price_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	price_lbl.add_theme_font_override("font", FONT)
	price_lbl.add_theme_font_size_override("font_size", 13)
	price_lbl.add_theme_color_override("font_color", FONT_COLOR)

	var qty_box = HBoxContainer.new()
	qty_box.custom_minimum_size   = Vector2(110, 0)
	qty_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	qty_box.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	qty_box.alignment             = BoxContainer.ALIGNMENT_CENTER
	qty_box.add_theme_constant_override("separation", 4)

	var minus_btn = Button.new()
	minus_btn.text                = "−"
	minus_btn.custom_minimum_size = Vector2(28, 28)
	minus_btn.pressed.connect(_on_minus.bind(prod_id))

	var qty_lbl = Label.new()
	qty_lbl.text                 = str(qty)
	qty_lbl.custom_minimum_size  = Vector2(32, 0)
	qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_lbl.size_flags_vertical  = Control.SIZE_SHRINK_CENTER
	qty_lbl.add_theme_font_override("font", FONT)
	qty_lbl.add_theme_font_size_override("font_size", 13)
	qty_lbl.add_theme_color_override("font_color", FONT_COLOR)

	var plus_btn = Button.new()
	plus_btn.text                = "+"
	plus_btn.custom_minimum_size = Vector2(28, 28)
	plus_btn.pressed.connect(_on_plus.bind(prod_id))

	qty_box.add_child(minus_btn)
	qty_box.add_child(qty_lbl)
	qty_box.add_child(plus_btn)

	var total_lbl = Label.new()
	total_lbl.text                  = "%.2f €" % subtotal
	total_lbl.custom_minimum_size   = Vector2(70, 0)
	total_lbl.size_flags_horizontal = Control.SIZE_SHRINK_END
	total_lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	total_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
	total_lbl.add_theme_font_override("font", FONT)
	total_lbl.add_theme_font_size_override("font_size", 13)
	total_lbl.add_theme_color_override("font_color", FONT_COLOR)

	row.add_child(img_wrapper)
	row.add_child(name_lbl)
	row.add_child(price_lbl)
	row.add_child(qty_box)
	row.add_child(total_lbl)

	panel.add_child(row)
	items_list.add_child(panel)

func _on_minus(prod_id) -> void:
	if not ProductManager.cart.has(prod_id):
		return
	ProductManager.cart[prod_id] -= 1
	if ProductManager.cart[prod_id] <= 0:
		ProductManager.cart.erase(prod_id)
	await _refresh_display(ProductManager.cart)

func _on_plus(prod_id) -> void:
	if not ProductManager.cart.has(prod_id):
		return
	ProductManager.cart[prod_id] += 1
	await _refresh_display(ProductManager.cart)

func _on_clear_btn_pressed() -> void:
	ProductManager.cart.clear()
	for child in items_list.get_children():
		child.queue_free()
	%SubtotalAmount.text = "0.00 €"
	%TotalAmount.text = "0.00 €"
	%TaxAmount.text = "0.00 €"
	%Badge.text       = "0"
