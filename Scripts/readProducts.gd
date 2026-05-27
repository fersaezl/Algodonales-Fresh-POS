extends Node

var products=[]
var productsFiltered=[]
var sections=[]

func _ready():
	products=readProducts()
	sections=readSections()
	searchProducts("ESTREllA GALICIA")
	print(productsFiltered)
	#productsSection("Vegetables")

func readProducts():
	var file = FileAccess.open("res://Assets/json/products.json", FileAccess.READ)
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent
	
func readSections():
	var file = FileAccess.open("res://Assets/json/sections.json", FileAccess.READ)
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
