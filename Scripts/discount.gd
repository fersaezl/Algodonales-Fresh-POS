extends CanvasLayer

signal discount_applied(amount: float)

@onready var discount_input = $PopupPanel/VBoxContainer/DiscountInput
@onready var apply_btn      = $PopupPanel/VBoxContainer/PopupButtons/ApplyBtn
@onready var cancel_btn     = $PopupPanel/VBoxContainer/PopupButtons/CancelBtn

func _ready():
	hide()

func open():
	discount_input.text = ""
	show()

func _on_apply():
	var value = discount_input.text
	if value.is_valid_float():
		var amount = float(value)
		discount_applied.emit(amount)
	hide()

func _on_cancel():
	hide()
