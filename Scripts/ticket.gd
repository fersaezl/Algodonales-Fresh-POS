extends Control

@onready var ticket_number = $CenterContainer/MainCard/VBoxContainer/TicketNumber
@onready var date_label    = $CenterContainer/MainCard/VBoxContainer/DateLabel
@onready var time_label    = $CenterContainer/MainCard/VBoxContainer/TimeLabel
@onready var cashier_label = $CenterContainer/MainCard/VBoxContainer/CashierLabel
@onready var items_list    = $CenterContainer/MainCard/VBoxContainer/ItemsList
@onready var total_amount  = $CenterContainer/MainCard/VBoxContainer/TotalRow/TotalAmount
@onready var amount_base   = $CenterContainer/MainCard/VBoxContainer/TotalRow/AmountBase
@onready var main_card     = $CenterContainer/MainCard
@onready var font = load("res://Assets/Fonts/COURBD.TTF")

func _ready():
	_fill_ticket()

func _fill_ticket():
	var date = Time.get_date_string_from_system()
	var time = Time.get_time_string_from_system()

	ticket_number.text = "Ticket No.: %04d" % ProductManager.ticket_number
	date_label.text    = "Date: %s" % date
	time_label.text    = "Time: %s" % time
	cashier_label.text = "Cashier: %s" % ProductManager.current_user

	for child in items_list.get_children():
		child.queue_free()

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

		var lbl_name = Label.new()
		lbl_name.text                   = pro.productName
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

	amount_base.text  = "%.2f €" % base_total
	total_amount.text = "%.2f €" % total

func _capture_main_card() -> Image:
	await RenderingServer.frame_post_draw
	var full_img  = get_viewport().get_texture().get_image()
	var card_pos  = main_card.get_global_position()
	var card_size = main_card.get_size()
	var rect      = Rect2i(int(card_pos.x), int(card_pos.y), int(card_size.x), int(card_size.y))
	return full_img.get_region(rect)

func _on_btn_download_pressed() -> void:
	var img = await _capture_main_card()
	var path = OS.get_user_data_dir() + "/ticket_%04d.png" % ProductManager.ticket_number
	img.save_png(path)
	OS.shell_open(OS.get_user_data_dir())
	
	ProductManager.save_sale("cash") 
	
	queue_free()

func _on_btn_cancel_pressed() -> void:
	queue_free()
