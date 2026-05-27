# THIS SCRIPT IS TO TEST THE FUNCTIONALITY OF THE SCENE TICKET. ALL THE UNRECOGNIZED FUNCTIONS OR
# VARIABLES WILL BE REMOVED WHEN IT WILL BE TESTED.

extends Control

@onready var ticket_number = $CenterContainer/MainCard/VBoxContainer/TicketNumber
@onready var date_label    = $CenterContainer/MainCard/VBoxContainer/DateLabel
@onready var time_label    = $CenterContainer/MainCard/VBoxContainer/TimeLabel
@onready var cashier_label = $CenterContainer/MainCard/VBoxContainer/CashierLabel
@onready var items_list    = $CenterContainer/MainCard/VBoxContainer/ItemsList
@onready var total_amount  = $CenterContainer/MainCard/VBoxContainer/TotalRow/TotalAmount
@onready var print_btn     = $CenterContainer/MainCard/VBoxContainer/PrintButton

func _ready():
	print_btn.pressed.connect(_on_print_pressed)
	_build_ticket()

func _build_ticket():
	ticket_number.text = "Ticket #:  %04d" % Cart.ticket_counter
	date_label.text    = "Date   :  %s" % Time.get_date_string_from_system()
	time_label.text    = "Time   :  %s" % Time.get_time_string_from_system()
	cashier_label.text = "Cashier:  %s" % Cart.current_cashier

	for child in items_list.get_children():
		child.queue_free()

	for item in Cart.items:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var name_lbl = Label.new()
		name_lbl.text = item["productName"].left(20)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 13)

		var qty_lbl = Label.new()
		qty_lbl.text = "x%d" % item["quantity"]
		qty_lbl.custom_minimum_size = Vector2(35, 0)
		qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty_lbl.add_theme_font_size_override("font_size", 13)

		var unit_lbl = Label.new()
		unit_lbl.text = "%.2f€" % item["price"]
		unit_lbl.custom_minimum_size = Vector2(60, 0)
		unit_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		unit_lbl.add_theme_font_size_override("font_size", 13)

		var sub_lbl = Label.new()
		sub_lbl.text = "%.2f€" % (item["price"] * item["quantity"])
		sub_lbl.custom_minimum_size = Vector2(65, 0)
		sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		sub_lbl.add_theme_font_size_override("font_size", 13)

		row.add_child(name_lbl)
		row.add_child(qty_lbl)
		row.add_child(unit_lbl)
		row.add_child(sub_lbl)
		items_list.add_child(row)

	total_amount.text = "%.2f€" % Cart.get_total()

func _on_print_pressed():
	var ticket_text = Cart.generate_ticket()
	var path = "user://ticket_%04d.txt" % (Cart.ticket_counter - 1)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(ticket_text)
	file.close()
	Cart.clear()
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")
