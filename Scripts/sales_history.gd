extends Control

@onready var items_list=$MarginContainer/MainLayout/MarginContainer/Content/SalesPanel/Cart/CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList

func _ready():
	historysales()

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
		
