extends Node

var products=[]
var productsFiltered=[]
var sections=[]
var cart={}
var prod
var current_user: String = ""
func _ready():
	products=readProducts()
	sections=readSections()
	save_sale()
	print(readHistory())
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
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent	
	
func productsSection(section):
	productsFiltered.clear()
	if section!=null:
		for pro in products:
			if(pro.section==section):
				productsFiltered.push_back(pro)
				#print(productsFiltered)
				
func searchProducts(string):
	productsFiltered.clear()
	for pro in products:
		if(string.to_lower() in pro.productName.to_lower()):
			productsFiltered.push_back(pro)
	if(productsFiltered.size()==0):
		print("No hay productos con eses filtro")
func searchProductByid(id):
	for pro in products:
		if(pro.id==id):
			return pro
func save_sale():
	if (cart==null):
		return
	var history = readHistory()
	var file_read = FileAccess.open("res://Data/historysales.json", FileAccess.READ)
	var next_id = history.size() + 1
	var new_sale={
		"sale_id": next_id,
		"user": current_user,
		"cart": cart
	}
	history.append(new_sale)
	
	var file = FileAccess.open("res://Data/historysales.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(history, "\t"))
	file.close()
