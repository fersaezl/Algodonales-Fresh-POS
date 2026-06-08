extends Control

@onready var ticket_number = $CenterContainer/MainCard/VBoxContainer/TicketNumber
@onready var date_label    = $CenterContainer/MainCard/VBoxContainer/DateLabel
@onready var time_label    = $CenterContainer/MainCard/VBoxContainer/TimeLabel
@onready var cashier_label = $CenterContainer/MainCard/VBoxContainer/CashierLabel
@onready var items_list    = $CenterContainer/MainCard/VBoxContainer/ItemsList
@onready var total_amount  = $CenterContainer/MainCard/VBoxContainer/TotalRow/TotalAmount
@onready var amount_base   = $CenterContainer/MainCard/VBoxContainer/TotalRow/AmountBase
@onready var main_card      = $CenterContainer/MainCard
@onready var font = load("res://Assets/Fonts/COURBD.TTF")

var is_historic : bool = false
var historic_data : Dictionary = {}

func _ready():
	_fill_ticket()

func set_historic_sale(sale_data: Dictionary) -> void:
	is_historic = true
	historic_data = sale_data

func _fill_ticket():
	for child in items_list.get_children():
		child.queue_free()

	if is_historic:
		var cart_data = historic_data.get("cart", {})
		var t_num = historic_data.get("ticket_number", historic_data.get("sale_id", 0))
		ticket_number.text = "Ticket No.: %04d" % int(t_num)
		
		var full_date = cart_data.get("date", "")
		date_label.text = "Date: %s" % full_date
		time_label.text = "Time: --:--:--"
		cashier_label.text = "Cashier: %s" % historic_data.get("user", "")

		var total := float(cart_data.get("total", 0.0))
		var base_total := total / (1.0 + ProductManager.tax_rate)

		var products_list = cart_data.get("products", [])
		for prod in products_list:
			var p_name = prod.get("productName", "")
			var p_price = float(prod.get("price", 0.0))
			var p_qty = int(prod.get("quantity", 1))
			_create_item_row(p_name, p_price, p_qty)

		amount_base.text  = "%.2f €" % base_total
		total_amount.text = "%.2f €" % total
	else:
		var date = Time.get_date_string_from_system()
		var time = Time.get_time_string_from_system()

		ticket_number.text = "Ticket No.: %04d" % ProductManager.ticket_number
		date_label.text    = "Date: %s" % date
		time_label.text    = "Time: %s" % time
		cashier_label.text = "Cashier: %s" % ProductManager.current_user

		var total      := 0.0
		var base_total := 0.0

		for prod_id in ProductManager.cart:
			var pro = ProductManager.searchProductByid(int(prod_id))
			if pro == null:
				continue
			var qty: int          = ProductManager.cart[prod_id]
			var price_with_tax    = float(pro.price)
			var price_without_tax = price_with_tax / (1.0 + ProductManager.tax_rate)
			var subtotal          = price_without_tax * qty
			total                += price_with_tax * qty
			base_total           += subtotal
			
			_create_item_row(pro.productName, price_with_tax, qty)

		amount_base.text  = "%.2f €" % base_total
		total_amount.text = "%.2f €" % total

func _create_item_row(p_name: String, price_with_tax: float, qty: int):
	var lbl_name = Label.new()
	lbl_name.text                   = p_name
	lbl_name.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	lbl_name.add_theme_font_override("font", font)
	lbl_name.add_theme_font_size_override("font_size", 12)
	lbl_name.add_theme_color_override("font_color", Color.BLACK)

	var lbl_price = Label.new()
	lbl_price.text                  = "%.2f €" % price_with_tax
	lbl_price.custom_minimum_size   = Vector2(60, 0)
	lbl_price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_price.add_theme_font_override("font", font)
	lbl_price.add_theme_font_size_override("font_size", 12)
	lbl_price.add_theme_color_override("font_color", Color.BLACK)

	var lbl_qty = Label.new()
	lbl_qty.text                    = str(qty)
	lbl_qty.custom_minimum_size     = Vector2(40, 0)
	lbl_qty.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	lbl_qty.add_theme_font_override("font", font)
	lbl_qty.add_theme_font_size_override("font_size", 12)
	lbl_qty.add_theme_color_override("font_color", Color.BLACK)

	var lbl_total = Label.new()
	lbl_total.text                  = "%.2f €" % (price_with_tax * qty)
	lbl_total.custom_minimum_size   = Vector2(70, 0)
	lbl_total.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_total.add_theme_font_override("font", font)
	lbl_total.add_theme_font_size_override("font_size", 12)
	lbl_total.add_theme_color_override("font_color", Color.BLACK)

	items_list.add_child(lbl_name)
	items_list.add_child(lbl_price)
	items_list.add_child(lbl_qty)
	items_list.add_child(lbl_total)

func _capture_main_card() -> Image:
	await RenderingServer.frame_post_draw
	var full_img  = get_viewport().get_texture().get_image()
	var card_pos  = main_card.get_global_position()
	var card_size = main_card.get_size()
	var rect      = Rect2i(int(card_pos.x), int(card_pos.y), int(card_size.x), int(card_size.y))
	return full_img.get_region(rect)

func _on_btn_download_pressed() -> void:
	var img = await _capture_main_card()
	var current_num = int(historic_data.get("ticket_number", historic_data.get("sale_id", ProductManager.ticket_number))) if is_historic else ProductManager.ticket_number
	if OS.get_name() == "Web":
		var png_data = img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(png_data, "ticket_%04d.png" % current_num, "image/png")
	else:
		var path = OS.get_user_data_dir() + "/ticket_%04d.png" % current_num
		img.save_png(path)
		OS.shell_open(OS.get_user_data_dir())
		
		if not is_historic:
			ProductManager.save_sale("cash")
			
		queue_free()

func _on_btn_cancel_pressed() -> void:
	queue_free()
