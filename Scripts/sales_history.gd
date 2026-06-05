extends Control

@onready var items_list=$MarginContainer/MainLayout/MarginContainer/Content/SalesPanel/Cart/CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList
@onready var btn_sales = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Sales
@onready var btn_history = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/History
@onready var btn_stock = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/MenuSection/Stock
@onready var username_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/UserName
@onready var datetime_label = $MarginContainer/MainLayout/TopBar/MarginContainer/HBoxContainer/RightSection/DateTime
@onready var itemListSummary=$MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Summary/CenterContainer/MainCard/VBoxContainer/ScrollArea/ItemsList
@onready var subTotal = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Summary/CenterContainer/MainCard/VBoxContainer/FooterPanel/FooterRow/LeftTotals/Subtotal/SubtotalAmount
@onready var taxes=$MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Summary/CenterContainer/MainCard/VBoxContainer/FooterPanel/FooterRow/LeftTotals/Taxes/TaxAmount
@onready var LBLtotal = $MarginContainer/MainLayout/MarginContainer/Content/PaymentPanel/MarginContainer/VBoxContainer/Summary/CenterContainer/MainCard/VBoxContainer/FooterPanel/FooterRow/RightTotal/TotalAmount

const TICKET_SCENE = preload("res://Scenes/Ticket.tscn")

var TotalSpent = 0.0
var totalSizes=0
var totalItemsSold=0
var averageSales
var selectedSale
func _ready():
	historysales("","")
	username_label.text = ProductManager.current_user
	_set_active_tab(btn_history)

func readHistory():
	var file = FileAccess.open("res://Data/historysales.json", FileAccess.READ)
	var content = file.get_as_text()
	var parseContent=JSON.parse_string(content)
	return parseContent	
func historysales(searchText , secondCondition ):
	var sales = readHistory()
	TotalSpent = 0.0
	totalSizes=0
	averageSales=0		
	totalItemsSold=0	

	if sales == null:
		return

	for child in items_list.get_children():
		child.queue_free()

	for sale in sales:
		var cartData = sale.get("cart")

		if searchText != "":
			if !str(cartData.get("date")).to_lower().contains(searchText.to_lower()) :
				continue

		if secondCondition != "":
			if !str(sale.get("user")).to_lower().contains(secondCondition.to_lower()):
				continue

		totalSizes += 1
		var row=HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.gui_input.connect(func(event): _on_row_clicked(event, sale))
		var cart_data=sale.get("cart")
		var dataSale=[
			str(sale.get("sale_id")),
			str(cart_data.get("date", "02/06/2026")),
			str(sale.get("user")),
			str(cart_data.get("products").size()),
			str(cart_data.get("total", 0.0)),
			str(sale.get("payment_method"))
		]
		TotalSpent+=float(cart_data.get("total"))
		totalItemsSold+=cart_data.get("products").size()
		%ItemsSold.text = str(int(totalItemsSold))
		%SalesAmount.text =str(snapped(TotalSpent, 0.01))+"€"
		for data in dataSale:
			var label=Label.new()
			label.text=data
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_color_override("font_color", Color.BLACK)
			row.add_child(label)
			
		items_list.add_child(row)
		averageSales = TotalSpent / int(totalSizes)
		%TicketAmount.text = "€" + str(snapped(averageSales, 0.01))
	%OrdersAmount.text = str(totalSizes)	
	if(totalSizes==0):
			%OrdersAmount.text="0€"
			%TicketAmount.text ="0€"
			%ItemsSold.text ="0€"
			%SalesAmount.text ="0€"	
		
func _on_row_clicked(event, sale_data):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		saleSelected(sale_data)		
		
func saleSelected(sale_data):
	var cartSale = sale_data.get("cart")
	selectedSale = sale_data
	%NumberInvoice.text = "INV-" + str(sale_data.get("sale_id"))
	%DateLbl.text = str(cartSale.get("date", "02/06/2026"))
	%Username.text = sale_data.get("user")
	%CardCash.text = sale_data.get("payment_method")
	
	for child in itemListSummary.get_children():
		child.queue_free()
		
	var productsDataList = cartSale.get("products")
	
	if(sale_data.get("payment_method") == "SAVE"):
		%saleButton.visible = true
	else:
		%saleButton.visible = false

	var subtotal = 0.0

	for prod in productsDataList:
		var row = HBoxContainer.new()
		var line_total = float(prod.get("price", 0.0)) * int(prod.get("quantity", 1))
		subtotal += line_total
		
		var dataProduct = [
			str(prod.get("productName")),
			str(prod.get("price")) + "€",
			str(prod.get("quantity")),
			str(snapped(line_total, 0.01)) + "€"
		]
		
		for data in dataProduct:
			var label = Label.new()
			label.text = data
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.add_theme_color_override("font_color", Color.BLACK)
			row.add_child(label)
		
		itemListSummary.add_child(row)

	var final_total = subtotal
	var tax = final_total - (final_total/1.21)

	subTotal.text = str(snapped(final_total/1.21, 0.01)) + " €"
	taxes.text = str(snapped(tax, 0.01)) + " €"
	LBLtotal.text = str(snapped(final_total, 0.01)) + " €"
	
	
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


func _on_button_pressed() -> void:
	historysales(%SearchBar.text, %SearchBar2.text)
	%OrdersAmount.text=str(totalSizes)
func _on_button_2_pressed() -> void:
	%SearchBar.text=""
	%SearchBar2.text=""
	historysales("","")


func _on_sale_button_pressed() -> void:
	ProductManager.cart.clear()
	var allProductsSale = selectedSale.get("cart").get("products")
	var cart = {}
	if str(selectedSale.get("payment_method")) == "SAVE":
		ProductManager.saveSaleId = int(selectedSale.get("sale_id"))

	for prod in allProductsSale:
		if prod.get("id") != 0:
			cart[prod.get("id")] = prod.get("quantity")		
	ProductManager.cart = cart
	
	get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")
	
func _on_ticket_pressed() -> void:
	if selectedSale == null:
		return
	var popup = TICKET_SCENE.instantiate()
	if popup.has_method("set_historic_sale"):
		popup.set_historic_sale(selectedSale)
	var layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	layer.add_child(popup)
	popup.tree_exiting.connect(layer.queue_free)


func _on_btn_logout_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Login.tscn")
