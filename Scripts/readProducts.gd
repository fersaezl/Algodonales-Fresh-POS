extends Node

var products=[]
var productsFiltered=[]
var sections=[]
var cart={}
var prod
func _ready():
	products=readProducts()
	sections=readSections()

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
