extends Node

var items: Array = []
var current_cashier: String = ""
var ticket_counter: int = 1

func add_product(product: Dictionary) -> void:
	for item in items:
		if item["productName"] == product["productName"]:
			item["quantity"] += 1
			return
	items.append({
		"productName": product["productName"],
		"price": product["price"],
		"quantity": 1
	})

func remove_product(product_name: String) -> void:
	for i in items.size():
		if items[i]["productName"] == product_name:
			items.remove_at(i)
			return

func get_total() -> float:
	var total := 0.0
	for item in items:
		total += item["price"] * item["quantity"]
	return total

func clear() -> void:
	items.clear()
