extends Control

@onready var username_input = $CenterContainer/mainCard/HBox/RightPanel/Username
@onready var password_input = $CenterContainer/mainCard/HBox/RightPanel/Password
@onready var login_btn      = $CenterContainer/mainCard/HBox/RightPanel/Login
@onready var error_label    = $CenterContainer/mainCard/HBox/RightPanel/ErrorLabel
@export var error_empty: String = ""
@export var error_invalid: String = ""

var users := []

func _ready():
	_load_users()

func _load_users():
	var file = FileAccess.open("res://Data/users.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		users = json.get_data()
		file.close()
	else:
		push_error("Error!")

func _on_login_pressed():
	var user  = username_input.text.strip_edges()
	var pass_ = password_input.text.strip_edges()

	if user.is_empty() or pass_.is_empty():
		_show_error(error_empty)
		return

	for u in users:
		if (u["dni"] == user or u["name"].to_lower() == user.to_lower()) and u["password"] == pass_:
			_show_error("")
			ProductManager.current_user = u["name"]
			get_tree().change_scene_to_file("res://Scenes/MainPos.tscn")
			return

	_show_error(error_invalid)

func _show_error(msg: String):
	error_label.text = msg
	error_label.visible = !msg.is_empty()
