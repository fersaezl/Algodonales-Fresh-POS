extends Node

var products=[]
var productsFiltered=[]
var sections=[]
var cart={}
var prod
var current_user: String = ""
var discount: float = 0.0
var tax_rate: float = 0.21
var ticket_number: int = 1

func _ready():
	products=readProducts()
	sections=readSections()
	_update_ticket_number_from_history()

func _update_ticket_number_from_history():
	var history = readHistory()
	if history.size() > 0:
		var last_sale = history[-1]
		if last_sale.has("ticket_number"):
			ticket_number = int(last_sale["ticket_number"]) + 1
		else:
			ticket_number = int(last_sale.get("sale_id", 0)) + 1
	else:
		ticket_number = 1

func readProducts():
	var file = FileAccess.open("res://Data/products.json", FileAccess.READ)
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent
	
func readSections():
	var file = FileAccess.open("res://Data/sections.json", FileAccess.READ)
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent
	
func readHistory():
	var file = FileAccess.open("res://Data/historysales.json", FileAccess.READ)
	if file == null:
		return []
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	if parseContent == null:
		return []
	return parseContent	
	
func productsSection(section):
	productsFiltered.clear()
	if section!=null:
		for pro in products:
			if(pro.section==section):
				productsFiltered.push_back(pro)
				
func searchProducts(string):
	productsFiltered.clear()
	for pro in products:
		if(string.to_lower() in pro.productName.to_lower()):
			productsFiltered.push_back(pro)
	if(productsFiltered.size()==0):
		print("No hay productos con eses filtro")

func searchProductByid(id):
	for pro in products:
		if(int(pro.id)==int(id)):
			return pro

func save_sale(payment):
	if (cart==null or cart.is_empty()):
		return
	var history = readHistory()
	var arrayCartProducts=[]
	var total=0.0
	var next_id = history.size() + 1
	
	for prod in cart:
		var quantity=cart[prod]
		var dataPROD=searchProductByid(int(prod))
		if dataPROD!=null:
			var price=dataPROD.get("price")
			total+=snapped((price*quantity)*1.21,0.01)
			var prodCart={
				"id":int(prod),
				"productName":dataPROD.get("productName"),
				"quantity":quantity,
				"price":price
			}
			arrayCartProducts.append(prodCart)
			
	var t = Time.get_datetime_dict_from_system()
	var formatedDate = "%02d/%02d/%04d" % [t.day, t.month, t.year]
	
	var new_sale={
		"sale_id": int(next_id),
		"ticket_number": int(ticket_number),
		"user": current_user,
		"payment_method":payment,
		"cart": {
			"products":arrayCartProducts,
			"total":total,
			"date":formatedDate
		}
	}
	history.append(new_sale)
	
	var file = FileAccess.open("res://Data/historysales.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(history, "\t"))
	file.close()
	
	ticket_number += 1

func get_subtotal() -> float:
	var total := 0.0
	for prod_id in cart:
		var pro = searchProductByid(prod_id)
		if pro:
			total += float(pro.price) * cart[prod_id]
	return total

func get_total() -> float:
	var sub = get_subtotal()
	return (sub - discount) * (1.0 + tax_rate)
