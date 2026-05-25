extends Node

var products=[]
var productsFiltered=[]

func ready():
	products=readProducts()

func readProducts():
	var file = FileAccess.open("res://Assets/products.json", FileAccess.READ)
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent

func productsSection(section):
	if section!=null:
		for pro in products:
			if(pro.section==section):
				productsFiltered.push(pro)
