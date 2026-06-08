extends Control

signal stock_updated

@onready var option_btn = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/OptionButton
@onready var spin_box = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/SpinBox
@onready var cancel_btn = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/CancelButton
@onready var save_btn = $ColorRect/CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/SaveButton

var all_products: Array = []

func _ready():
	all_products = ProductManager.products
	_populate_products()
	
	cancel_btn.pressed.connect(_on_cancel_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	option_btn.item_selected.connect(_on_product_selected)

func _populate_products() -> void:
	option_btn.clear()
	for idx in range(all_products.size()):
		var p = all_products[idx]
		option_btn.add_item(p["productName"])
		option_btn.set_item_metadata(idx, idx)
		
	if all_products.size() > 0:
		spin_box.value = int(all_products[0]["stock"])

func _on_product_selected(index: int) -> void:
	var prod_idx = option_btn.get_item_metadata(index)
	spin_box.value = int(all_products[prod_idx]["stock"])

func _on_cancel_pressed() -> void:
	queue_free()

func _on_save_pressed() -> void:
	if option_btn.get_item_count() == 0:
		queue_free()
		return
		
	var selected_idx = option_btn.get_item_metadata(option_btn.selected)
	var new_stock = int(spin_box.value)
	
	ProductManager.products[selected_idx]["stock"] = new_stock
	
	stock_updated.emit()
	queue_free()
