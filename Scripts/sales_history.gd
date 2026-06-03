extends Control

@onready var items_list=$MarginContainer/MainLayout/MarginContainer/Content/SalesPanel/Cart/CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList
@onready var btn_sales = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Sales
@onready var btn_history = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/History
@onready var btn_stock = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Stock
@onready var username_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/UserName
@onready var datetime_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/DateTime

func _ready():
	historysales()
	username_label.text = ProductManager.current_user
	_set_active_tab(btn_history)

func readHistory():
	var file = FileAccess.open("res://Data/historysales.json", FileAccess.READ)
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent	
func historysales():
	var sales=readHistory()
	if (sales==null):
		return
	for child in items_list.get_children():
		child.queue_free()
	for sale in sales:
		var row=HBoxContainer.new()
		var cart_data=sale.get("cart")
		var dataSale=[
			str(sale.get("sale_id")),
			str(cart_data.get("date", "02/06/2026")),
			str(sale.get("user")),
			str(cart_data.get("productos", []).size()),
			str(cart_data.get("total", 0.0)),
			str(cart_data.get("payment_method", "Card"))
		]
		
		for data in dataSale:
			var label=Label.new()
			label.text=data
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", Color.BLACK)
			row.add_child(label)
			
		items_list.add_child(row)
		
func _process(_delta) -> void:
	var t = Time.get_datetime_dict_from_system()
	datetime_label.text = "%02d/%02d/%04d  %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]
	
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

func _on_sales_pressed() -> void:
	_set_active_tab(btn_sales)
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")

func _on_history_pressed() -> void:
	_set_active_tab(btn_history)
	get_tree().change_scene_to_file("res://Scenes/SalesHistory.tscn")

func _on_stock_pressed() -> void:
	_set_active_tab(btn_stock)
	get_tree().change_scene_to_file("res://Scenes/Stock.tscn")
