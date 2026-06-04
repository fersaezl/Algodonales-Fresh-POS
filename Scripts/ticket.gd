extends Control

@onready var ticket_number  = $CenterContainer/MainCard/VBoxContainer/TicketNumber
@onready var date_label     = $CenterContainer/MainCard/VBoxContainer/DateLabel
@onready var time_label     = $CenterContainer/MainCard/VBoxContainer/TimeLabel
@onready var cashier_label  = $CenterContainer/MainCard/VBoxContainer/CashierLabel
@onready var items_list     = $CenterContainer/MainCard/VBoxContainer/ItemsList
@onready var total_amount   = $CenterContainer/MainCard/VBoxContainer/TotalRow/TotalAmount
@onready var main_card      = $CenterContainer/MainCard

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

	for prod_id in ProductManager.cart:
		var pro = ProductManager.searchProductByid(prod_id)
		if pro == null:
			continue
		var qty: int        = ProductManager.cart[prod_id]
		var subtotal: float = float(pro.price) * qty
		var row             = HBoxContainer.new()

		var lbl_name = Label.new()
		lbl_name.text                  = pro.productName
		lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var lbl_qty = Label.new()
		lbl_qty.text                 = str(qty)
		lbl_qty.custom_minimum_size  = Vector2(40, 0)
		lbl_qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var lbl_unit = Label.new()
		lbl_unit.text                = "ud"
		lbl_unit.custom_minimum_size = Vector2(40, 0)

		var lbl_sub = Label.new()
		lbl_sub.text                 = "%.2f€" % subtotal
		lbl_sub.custom_minimum_size  = Vector2(70, 0)
		lbl_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		row.add_child(lbl_name)
		row.add_child(lbl_qty)
		row.add_child(lbl_unit)
		row.add_child(lbl_sub)
		items_list.add_child(row)

	total_amount.text = "%.2f€" % ProductManager.get_total()

func _capture_main_card() -> Image:
	await RenderingServer.frame_post_draw
	var full_img = get_viewport().get_texture().get_image()
	var card_pos  = main_card.get_global_position()
	var card_size = main_card.get_size()
	var rect = Rect2i(int(card_pos.x), int(card_pos.y), int(card_size.x), int(card_size.y))
	return full_img.get_region(rect)

func _on_btn_download_pressed() -> void:
	var img  = await _capture_main_card()
	var path = OS.get_user_data_dir() + "/ticket_%04d.png" % ProductManager.ticket_number
	img.save_png(path)
	OS.shell_open(OS.get_user_data_dir())

func _on_btn_cancel_pressed() -> void:
	queue_free()
